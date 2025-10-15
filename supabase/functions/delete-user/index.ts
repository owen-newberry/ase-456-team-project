// @ts-ignore
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  const supabase = createClient(
    // @ts-ignore
    Deno.env.get("URL_FOR_SUPABASE") ?? "",
    // @ts-ignore
    Deno.env.get("SERVICE_ROLE_KEY") ?? ""
  );

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return new Response("Missing Authorization header", { status: 401 });

  const token = authHeader.replace("Bearer ", "");
  const { data: { user }, error: userError } = await supabase.auth.getUser(token);

  if (userError || !user) return new Response("Invalid or missing user", { status: 401 });

  const { error } = await supabase.auth.admin.deleteUser(user.id);
  if (error) return new Response(JSON.stringify(error), { status: 400 });

  return new Response(JSON.stringify({ success: true }), { status: 200 });
});
