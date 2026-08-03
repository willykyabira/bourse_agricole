import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// URL de l'API PawaPay selon l'environnement
const isSandbox = Deno.env.get("PAWAPAY_SANDBOX") === "true";
const PAWAPAY_BASE_URL = isSandbox
  ? "https://api.sandbox.pawapay.io"
  : "https://api.pawapay.io";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Gestion du preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("PAWAPAY_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "PAWAPAY_API_KEY non configurée" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const payload = await req.json();

    // Validation des champs obligatoires
    const { amount, referenceCommande, reason } = payload;
    if (!amount || !referenceCommande) {
      return new Response(
        JSON.stringify({ error: "amount et referenceCommande sont requis" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Génération d'un UUID v4 pour le depositId
    const depositId = crypto.randomUUID();

    // URL de retour après paiement — utilise la function pawa-return
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const returnUrl = `${supabaseUrl}/functions/v1/pawa-return?depositId=${depositId}&reference=${encodeURIComponent(referenceCommande)}`;

    // Formater le montant (en entier, sans décimales)
    const amountNum = Math.round(Number(amount));
    const amountStr = amountNum.toString();

    // Corps de la requête vers l'API PawaPay Payment Page
    const requestBody: Record<string, unknown> = {
      depositId,
      returnUrl,
      statementDescription: "BAN ITURI",
      amount: amountStr,
      language: "FR",
      country: "COD", // République Démocratique du Congo
      metadata: [
        {
          fieldName: "referenceCommande",
          fieldValue: referenceCommande,
        },
      ],
    };

    // Ajouter la raison si fournie
    if (reason) {
      requestBody.reason = String(reason).substring(0, 50);
    }

    console.log(`[pawa-payment-page] Création session — depositId: ${depositId}, amount: ${amountStr}, sandbox: ${isSandbox}`);

    const response = await fetch(`${PAWAPAY_BASE_URL}/v1/widget/sessions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
        "User-Agent": "BourseAgricole-Edge/2.0",
      },
      body: JSON.stringify(requestBody),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error(`[pawa-payment-page] Erreur PawaPay ${response.status}:`, JSON.stringify(data));
      return new Response(
        JSON.stringify({
          error: data.errorMessage ?? "Erreur lors de la création de la session",
          details: data,
        }),
        {
          status: response.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Retourner l'URL de redirection + le depositId pour suivi
    return new Response(
      JSON.stringify({
        redirectUrl: data.redirectUrl,
        depositId,
        referenceCommande,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[pawa-payment-page] Erreur inattendue:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
