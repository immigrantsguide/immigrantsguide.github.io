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
.card{width:min(450px,100%);background:#fff;border:1px solid #e2e8f0;border-radius:16px;padding:32px;box-shadow:0 15px 45px #0f172a18}
.logo{font-size:23px;font-weight:800}.logo span{color:#2563eb}
.subtitle{color:#64748b;margin:8px 0 25px}
label{display:block;font-size:13px;font-weight:700;margin:16px 0 7px}
input{width:100%;padding:13px;border:1px solid #cbd5e1;border-radius:9px;font-size:15px}
button{width:100%;margin-top:20px;padding:13px;border:0;border-radius:9px;background:#2563eb;color:#fff;font-weight:700;font-size:15px;cursor:pointer}
button:disabled{opacity:.65;cursor:wait}
.back{display:block;text-align:center;margin-top:18px;color:#2563eb;text-decoration:none;font-size:14px}
.msg{margin-top:15px;padding:12px;border-radius:9px;font-size:13px;line-height:1.5;display:none}
.msg.err{display:block;background:#fef2f2;color:#991b1b}
.msg.ok{display:block;background:#ecfdf5;color:#166534}
.msg.info{display:block;background:#eff6ff;color:#1d4ed8}
.debug{margin-top:15px;padding:12px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:9px;font-size:12px;color:#475569;display:none}
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
  <div id="debug" class="debug"></div>
  <a class="back" href="index.html">← Back to USCIS Case Status</a>
</div>

<script>
(function(){
"use strict";

const SUPABASE_URL="https://euzifpjzeuqdznkelxdq.supabase.co";
const SUPABASE_KEY="sb_publishable_peFBAVgb_bBF0DbZYpBl_A_ZTu8XWVe";

const db=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY,{
  auth:{
    persistSession:true,
    autoRefreshToken:true,
    detectSessionInUrl:true
  }
});

const $=id=>document.getElementById(id);

function show(text,type){
  $("msg").className="msg "+type;
  $("msg").textContent=text;
}

function debug(text){
  $("debug").style.display="block";
  $("debug").textContent=text;
}

// IMPORTANT: Do not redirect before the login result is known.
// This lets us see exactly what Supabase returns.
$("loginForm").addEventListener("submit",async e=>{
  e.preventDefault();

  const email=$("email").value.trim();
  const password=$("password").value;
  const btn=$("loginBtn");

  btn.disabled=true;
  btn.textContent="Signing in...";
  show("Connecting to Supabase...","info");
  $("debug").style.display="none";

  try{
    const result=await db.auth.signInWithPassword({email,password});

    console.log("Supabase signIn result:",result);

    if(result.error){
      throw result.error;
    }

    if(!result.data?.session){
      throw new Error("Supabase accepted the login but did not return a session.");
    }

    show("Login successful. Verifying browser session...","ok");

    // Explicitly persist the returned session.
    const session=result.data.session;

    const setResult=await db.auth.setSession({
      access_token:session.access_token,
      refresh_token:session.refresh_token
    });

    if(setResult.error){
      throw setResult.error;
    }

    const check=await db.auth.getSession();

    if(!check.data?.session){
      throw new Error("Login succeeded, but the browser could not persist the Supabase session.");
    }

    debug(
      "Authentication successful.\n"+
      "User: "+(check.data.session.user?.email||email)+"\n"+
      "Session: ACTIVE\n"+
      "Opening dashboard..."
    );

    setTimeout(()=>{
      window.location.assign("dashboard.html?auth=1");
    },700);

  }catch(err){
    console.error("LOGIN ERROR:",err);

    let text=err?.message||"Login failed.";

    if(text.toLowerCase().includes("invalid login credentials")){
      text="Invalid email or password.";
    }

    if(text.toLowerCase().includes("email not confirmed")){
      text="Your Supabase account email is not confirmed. Confirm the email in Supabase Authentication first.";
    }

    show(text,"err");
    debug("Supabase authentication did not complete. Check the error above.");
    btn.disabled=false;
    btn.textContent="Log In";
  }
});

// Show existing session without redirecting automatically.
db.auth.getSession().then(({data,error})=>{
  if(error){
    console.error(error);
    return;
  }

  if(data?.session){
    show("A Supabase session is already active. You can open the dashboard.","ok");
    debug("Existing session: ACTIVE");
  }
});
})();
</script>
</body>
</html>
