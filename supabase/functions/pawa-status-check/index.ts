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
    const { depositId } = payload;

    if (!depositId) {
      return new Response(
        JSON.stringify({ error: "depositId est requis" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    console.log(`[pawa-status-check] Vérification statut — depositId: ${depositId}`);

    const response = await fetch(`${PAWAPAY_BASE_URL}/v1/deposits/${depositId}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
        "User-Agent": "BourseAgricole-Edge/2.0",
      },
    });

    const data = await response.json();

    if (!response.ok) {
      console.error(`[pawa-status-check] Erreur PawaPay ${response.status}:`, JSON.stringify(data));
      return new Response(
        JSON.stringify({
          error: data.errorMessage ?? "Erreur lors de la vérification du statut",
          details: data,
        }),
        {
          status: response.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // L'API renvoie un tableau; on prend le premier élément
    const deposit = Array.isArray(data) ? data[0] : data;

    console.log(`[pawa-status-check] Statut: ${deposit?.status} — depositId: ${depositId}`);

    return new Response(
      JSON.stringify({
        depositId: deposit?.depositId ?? depositId,
        status: deposit?.status ?? "UNKNOWN",
        amount: deposit?.amount,
        currency: deposit?.currency,
        created: deposit?.created,
        correspondent: deposit?.correspondent,
        payer: deposit?.payer,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("[pawa-status-check] Erreur inattendue:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
