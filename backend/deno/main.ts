// Point d'entrée du backend Deno

import { Application } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import router from "./routes/index.ts";

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

console.log("Serveur Deno lancé sur http://localhost:8000 ");
await app.listen({ port: 8000 });
