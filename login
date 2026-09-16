<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Immigrants Guide — Login</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
*{box-sizing:border-box}
body{
  margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
  font-family:Inter,Arial,sans-serif;background:#f4f7fb;color:#172033;
}
.card{
  width:min(430px,92vw);background:#fff;border:1px solid #e3e8f0;
  border-radius:18px;padding:32px;box-shadow:0 15px 45px rgba(20,35,60,.10);
}
h1{margin:0 0 8px;font-size:27px}
.sub{margin:0 0 25px;color:#667085}
label{display:block;font-size:14px;font-weight:700;margin:16px 0 7px}
input{
  width:100%;padding:13px 14px;border:1px solid #ccd5e1;border-radius:10px;
  font-size:15px;outline:none;
}
input:focus{border-color:#2563eb;box-shadow:0 0 0 3px rgba(37,99,235,.10)}
button{
  width:100%;margin-top:22px;padding:13px;border:0;border-radius:10px;
  background:#2563eb;color:#fff;font-size:16px;font-weight:700;cursor:pointer;
}
button:disabled{opacity:.65;cursor:not-allowed}
.status{
  display:none;margin-top:16px;padding:12px 14px;border-radius:10px;
  font-size:14px;line-height:1.45;white-space:pre-wrap;
}
.info{display:block;background:#eef5ff;color:#174ea6}
.success{display:block;background:#ecfdf3;color:#067647}
.error{display:block;background:#fef3f2;color:#b42318}
.back{display:block;text-align:center;margin-top:18px;color:#2563eb;text-decoration:none;font-size:14px}
.small{margin-top:18px;text-align:center;color:#98a2b3;font-size:12px}
</style>
</head>
<body>
<div class="card">
  <h1>Welcome back</h1>
  <p class="sub">Sign in to your Immigrants Guide USCIS Case Tracker.</p>

  <form id="loginForm" novalidate>
    <label for="email">Email</label>
    <input id="email" type="email" autocomplete="username" required>

    <label for="password">Password</label>
    <input id="password" type="password" autocomplete="current-password" required>

    <button id="loginBtn" type="submit">Login</button>
  </form>

  <div id="status" class="status"></div>
  <a class="back" href="index.html">← Back to Case Tracker</a>
  <div class="small">Immigrants Guide</div>
</div>

<script>
(function(){
  const SUPABASE_URL = "https://euzifpjzeuqdznkelxdq.supabase.co";
  const SUPABASE_KEY = "sb_publishable_peFBAVgb_bBF0DbZYpBl_A_ZTu8XWVe";

  const statusEl = document.getElementById("status");
  const form = document.getElementById("loginForm");
  const btn = document.getElementById("loginBtn");

  function show(message, type){
    statusEl.className = "status " + type;
    statusEl.textContent = message;
  }

  function setBusy(busy){
    btn.disabled = busy;
    btn.textContent = busy ? "Signing in..." : "Login";
  }

  if (!window.supabase || !window.supabase.createClient) {
    show("Supabase library did not load. Please refresh the page.", "error");
    return;
  }

  const supabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_KEY,
    {
      auth:{
        persistSession:true,
        autoRefreshToken:true,
        detectSessionInUrl:true
      }
    }
  );

  form.addEventListener("submit", async function(e){
    e.preventDefault();

    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value;

    if(!email || !password){
      show("Please enter both email and password.", "error");
      return;
    }

    setBusy(true);
    show("Signing in...", "info");

    try{
      // signInWithPassword itself creates and persists the browser session.
      // Do not call setSession again here; doing so can race refresh-token handling.
      const result = await Promise.race([
        supabase.auth.signInWithPassword({email, password}),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error("Login request timed out. Please refresh and try again.")), 15000)
        )
      ]);

      const { data, error } = result;

      if(error){
        const msg = String(error.message || "Unable to sign in.");
        if(/invalid login credentials/i.test(msg)){
          show("Invalid email or password.", "error");
        }else if(/email not confirmed/i.test(msg)){
          show("Your email address has not been confirmed in Supabase Auth.", "error");
        }else{
          show(msg, "error");
        }
        setBusy(false);
        return;
      }

      if(!data || !data.session || !data.session.access_token){
        show("Supabase accepted the login but did not return an active session. Please try again.", "error");
        setBusy(false);
        return;
      }

      show("Login successful. Opening dashboard...", "success");

      // Give the browser a moment to persist the session, then navigate.
      setTimeout(function(){
        window.location.replace("dashboard.html?auth=1");
      }, 300);

    }catch(err){
      console.error("LOGIN_ERROR", err);
      show("Login error: " + (err && err.message ? err.message : String(err)), "error");
      setBusy(false);
    }
  });
})();
</script>
</body>
</html>
