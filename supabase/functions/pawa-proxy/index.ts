import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const PAWAPAY_SANDBOX_URL = "https://api.sandbox.pawapay.cloud"; // URL exacte à vérifier selon doc
const API_TOKEN = Deno.env.get("PAWAPAY_API_TOKEN");

serve(async (req) => {
  // Gestion du CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const body = await req.json();
    
    const response = await fetch(`${PAWAPAY_SANDBOX_URL}/v1/payments`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${API_TOKEN}`,
      },
      body: JSON.stringify({
        amount: body.amount,
        currency: "CDF",
        reference: body.reference,
        customer: { phone: body.phoneNumber },
        operator: body.operator,
      }),
    });

    const data = await response.json();

    return new Response(JSON.stringify(data), {
      status: response.status,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
