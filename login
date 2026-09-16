<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Immigrants Guide — Staff Login</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
*{box-sizing:border-box}
body{margin:0;min-height:100vh;font-family:Arial,sans-serif;background:#f5f7fb;color:#172033;display:flex;align-items:center;justify-content:center;padding:20px}
.card{width:min(430px,100%);background:#fff;border:1px solid #e2e8f0;border-radius:16px;padding:32px;box-shadow:0 15px 45px #0f172a18}
.logo{font-size:23px;font-weight:800;color:#172033}.logo span{color:#2563eb}
.subtitle{color:#64748b;margin:8px 0 28px}
label{display:block;font-size:13px;font-weight:700;margin:16px 0 7px}
input{width:100%;padding:13px;border:1px solid #cbd5e1;border-radius:9px;font-size:15px}
button{width:100%;margin-top:20px;padding:13px;border:0;border-radius:9px;background:#2563eb;color:#fff;font-weight:700;font-size:15px;cursor:pointer}
button:disabled{opacity:.65;cursor:wait}
.back{display:block;text-align:center;margin-top:18px;color:#2563eb;text-decoration:none;font-size:14px}
.msg{display:none;margin-top:15px;padding:11px;border-radius:9px;font-size:13px;line-height:1.45}
.msg.err{display:block;background:#fef2f2;color:#991b1b}
.msg.info{display:block;background:#eff6ff;color:#1d4ed8}
</style>
</head>
<body>
<div class="card">
  <div class="logo">Immigrants <span>Guide</span></div>
  <div class="subtitle">Secure staff login</div>

  <form id="loginForm">
    <label for="email">Email</label>
    <input id="email" type="email" autocomplete="username" required>

    <label for="password">Password</label>
    <input id="password" type="password" autocomplete="current-password" required>

    <button id="loginBtn" type="submit">Log In</button>
  </form>

  <div id="msg" class="msg"></div>
  <a class="back" href="index.html">← Back to USCIS Case Status</a>
</div>

<script>
(function(){
  "use strict";

  const SUPABASE_URL = "https://euzifpjzeuqdznkelxdq.supabase.co".replace("xdxq","xdxq");
  const SUPABASE_KEY = "sb_publishable_peFBAVgb_bBF0DbZYpBl_A_ZTu8XWVe";

  const db = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_KEY,
    {
      auth:{
        autoRefreshToken:true,
        persistSession:true,
        detectSessionInUrl:true
      }
    }
  );

  const $ = id => document.getElementById(id);

  function message(text,type){
    $("msg").className="msg "+type;
    $("msg").textContent=text;
  }

  // If already logged in, go directly to dashboard.
  db.auth.getSession().then(({data,error})=>{
    if(error){
      console.error("Session check:",error);
      return;
    }
    if(data?.session){
      window.location.replace("dashboard.html");
    }
  });

  $("loginForm").addEventListener("submit",async function(e){
    e.preventDefault();

    const email=$("email").value.trim();
    const password=$("password").value;
    const btn=$("loginBtn");

    btn.disabled=true;
    btn.textContent="Signing in...";
    message("Signing in...","info");

    try{
      const {data,error}=await db.auth.signInWithPassword({
        email,
        password
      });

      if(error) throw error;

      if(!data?.session){
        throw new Error("Login succeeded, but no session was created. Please try again.");
      }

      message("Login successful. Opening dashboard...","info");

      // Give Supabase a moment to persist the session.
      setTimeout(()=>{
        window.location.href="dashboard.html";
      },300);

    }catch(err){
      console.error("Login error:",err);

      let text=err?.message || "Login failed. Please try again.";

      if(text.toLowerCase().includes("invalid login credentials")){
        text="Invalid email or password.";
      }

      message(text,"err");
      btn.disabled=false;
      btn.textContent="Log In";
    }
  });
})();
</script>
</body>
</html>
