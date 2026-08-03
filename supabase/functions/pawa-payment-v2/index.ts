import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const PAWAPAY_BASE_URL = Deno.env.get('PAWAPAY_SANDBOX') === 'true' 
  ? "https://api.sandbox.pawapay.io/v2" 
  : "https://api.pawapay.io/v2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const apiKey = Deno.env.get('PAWAPAY_API_KEY');
    if (!apiKey) throw new Error("PAWAPAY_API_KEY non configurée");

    const payload = await req.json();

    const depositId = crypto.randomUUID();
    let phoneNumber = (payload.phoneNumber || '').replace(/^\+/, '');

    // Aide Sandbox : si on est en sandbox et que ce n'est pas déjà un numéro de test
    const isSandbox = Deno.env.get('PAWAPAY_SANDBOX') === 'true';
    if (isSandbox && !phoneNumber.includes("3456")) {
      const op = (payload.operator || "").toUpperCase();
      if (op.includes("VODACOM")) {
        phoneNumber = "243813456789"; // Succès Vodacom RDC
      } else if (op.includes("AIRTEL")) {
        phoneNumber = "243973456789"; // Succès Airtel RDC
      } else if (op.includes("ORANGE")) {
        phoneNumber = "243893456789"; // Succès Orange RDC
      } else {
        phoneNumber = "243813456789";
      }
    }

    // Table de correspondance pour les opérateurs RDC attendus par PawaPay
    const operatorMap: Record<string, string> = {
      "ORANGE": "ORANGE_COD",
      "VODACOM": "VODACOM_MPESA_COD",
      "AIRTEL": "AIRTEL_COD"
    };

    const provider = operatorMap[payload.operator.toUpperCase()] || payload.operator;

    // Formater le montant pour s'assurer qu'il a deux décimales
    const amount = Number(payload.amount).toFixed(2);

    const requestBody = {
      depositId,
      amount,
      currency: payload.currency || "CDF",
      payer: {
        type: "MMO",
        accountDetails: {
          phoneNumber,
          provider
        }
      },
      clientReferenceId: payload.reference,
    };

    const response = await fetch(`${PAWAPAY_BASE_URL}/deposits`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
        "User-Agent": "BourseAgricole-Edge/1.0"
      },
      body: JSON.stringify(requestBody),
    });

    const data = await response.json();
    
    return new Response(JSON.stringify(data), {
      status: response.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
