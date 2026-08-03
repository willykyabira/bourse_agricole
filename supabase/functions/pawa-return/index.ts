import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

/**
 * pawa-return : URL de retour après la PawaPay Payment Page.
 *
 * PawaPay redirige l'utilisateur vers cette URL après le paiement.
 * Elle reçoit les paramètres de query :
 *   - depositId : l'identifiant du dépôt
 *   - reference  : la référence de commande (ajoutée lors de la création)
 *
 * Cette fonction affiche une page HTML simple informant l'utilisateur
 * de revenir dans l'application BAN pour confirmer son paiement.
 */
serve(async (req) => {
  const url = new URL(req.url);
  const depositId = url.searchParams.get("depositId") ?? "";
  const reference = url.searchParams.get("reference") ?? "";

  console.log(`[pawa-return] Retour PawaPay — depositId: ${depositId}, reference: ${reference}`);

  // Page HTML de retour affichée dans le navigateur
  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Retour de paiement — BAN ITURI</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #0B5E34 0%, #1565C0 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .card {
      background: white;
      border-radius: 20px;
      padding: 40px 32px;
      max-width: 420px;
      width: 100%;
      text-align: center;
      box-shadow: 0 20px 60px rgba(0,0,0,0.15);
    }
    .icon {
      width: 72px;
      height: 72px;
      background: #e8f5e9;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      font-size: 36px;
    }
    h1 {
      color: #0B5E34;
      font-size: 22px;
      font-weight: 700;
      margin-bottom: 12px;
    }
    p {
      color: #555;
      font-size: 15px;
      line-height: 1.6;
      margin-bottom: 10px;
    }
    .ref {
      background: #f5f5f5;
      border-radius: 10px;
      padding: 12px 16px;
      margin: 20px 0;
      font-size: 13px;
      color: #333;
      word-break: break-all;
    }
    .ref strong { color: #0B5E34; }
    .btn {
      display: inline-block;
      background: #0B5E34;
      color: white;
      border: none;
      border-radius: 12px;
      padding: 14px 28px;
      font-size: 15px;
      font-weight: 600;
      cursor: pointer;
      text-decoration: none;
      margin-top: 8px;
    }
    .logo {
      font-size: 13px;
      color: #aaa;
      margin-top: 24px;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">✅</div>
    <h1>Paiement soumis !</h1>
    <p>
      Votre paiement a été soumis à PawaPay. 
      Revenez dans l'application <strong>BAN ITURI</strong> et 
      appuyez sur <strong>"J'ai effectué le paiement"</strong> 
      pour confirmer et générer votre facture.
    </p>
    ${depositId ? `
    <div class="ref">
      <strong>Référence dépôt :</strong><br/>
      ${depositId}
    </div>
    ` : ""}
    <p style="font-size:13px; color:#888;">
      Vous pouvez maintenant fermer cette page et retourner dans l'application.
    </p>
    <div class="logo">BAN ITURI • Bourse Agricole du Nord</div>
  </div>
</body>
</html>`;

  return new Response(html, {
    status: 200,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Access-Control-Allow-Origin": "*",
    },
  });
});
