import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  // Handle CORS for browser requests
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  const apiKey = Deno.env.get('PAWAPAY_API_KEY');
  const isSandbox = Deno.env.get('PAWAPAY_SANDBOX') === 'true';
  const baseUrl = isSandbox ? "https://api.sandbox.pawapay.cloud" : "https://api.pawapay.com";

  if (!apiKey) {
    return new Response(JSON.stringify({ error: "Configuration API manquante" }), { status: 500 });
  }

  try {
    const body = await req.json();
    
    const response = await fetch(`${baseUrl}/v1/payments`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        amount: body.amount,
        currency: body.currency || "CDF",
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
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }
});
