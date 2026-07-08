import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // 1. Lecture sécurisée du secret
  const apiKey = Deno.env.get('PAWAPAY_API_KEY');

  if (!apiKey) {
    return new Response(JSON.stringify({ error: "Configuration API manquante" }), { status: 500 });
  }

  const body = await req.json();
  const { montant, telephone, commandeId, reseau, devise } = body;

  // 2. Appel vers PawaPay
  const response = await fetch('https://api.pawapay.com/v1/payments', { 
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      // On utilise le secret ici, pas la clé en dur
      'Authorization': `Bearer ${apiKey}`, 
    },
    body: JSON.stringify({
      amount: montant,
      currency: devise,
      reference: commandeId,
      customer: { phone: telephone },
      operator: reseau,
    }),
  });

  const data = await response.json();

  if (response.ok) {
    return new Response(JSON.stringify(data), { status: 200 });
  } else {
    // Si PawaPay renvoie 401 ici, c'est que la clé est mauvaise ou expirée
    return new Response(JSON.stringify(data), { status: response.status });
  }
})