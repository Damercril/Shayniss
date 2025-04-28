import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création d’une catégorie valide
Deno.test("POST /categories - succès", async () => {
  const res = await fetch("http://localhost:8000/categories", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Bien-être" })
  });
  const body = await res.json();
  console.log("Création catégorie:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.name, "Bien-être");
});

// Test 2 : Création avec nom vide
Deno.test("POST /categories - nom vide", async () => {
  const res = await fetch("http://localhost:8000/categories", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "" })
  });
  const body = await res.json();
  console.log("Erreur nom vide:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Le nom de la catégorie ne peut pas être vide.");
});

// Test 3 : Création avec nom déjà existant
Deno.test("POST /categories - nom déjà existant", async () => {
  await fetch("http://localhost:8000/categories", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Bien-être" })
  });
  const res = await fetch("http://localhost:8000/categories", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Bien-être" })
  });
  const body = await res.json();
  console.log("Erreur nom déjà existant:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Une catégorie avec ce nom existe déjà.");
});

// Test 4 : GET /categories/:id existant
Deno.test("GET /categories/:id - succès", async () => {
  // Crée une catégorie pour le test
  const create = await fetch("http://localhost:8000/categories", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Beauté" })
  });
  const created = await create.json();
  const res = await fetch(`http://localhost:8000/categories/${created.id}`);
  const body = await res.json();
  console.log("Récupération catégorie:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.id, created.id);
});

// Test 5 : GET /categories/:id inexistant
Deno.test("GET /categories/:id - not found", async () => {
  const res = await fetch("http://localhost:8000/categories/id-inexistant");
  const body = await res.json();
  console.log("Erreur catégorie inexistante:", res.status, body);
  assertEquals(res.status, 404);
  assertEquals(body.error, "Catégorie non trouvée.");
});

// Test 6 : GET /categories?search=Bea&limit=1&offset=0
Deno.test("GET /categories?search=Bea&limit=1&offset=0", async () => {
  const res = await fetch("http://localhost:8000/categories?search=Bea&limit=1&offset=0");
  const body = await res.json();
  console.log("Liste filtrée/paginée:", res.status, body);
  assertEquals(res.status, 200);
  if (body.length > 1) {
    throw new Error("Pagination incorrecte");
  }
  for (const c of body) {
    if (!c.name.toLowerCase().includes("bea")) {
      throw new Error("Filtrage incorrect");
    }
  }
});
