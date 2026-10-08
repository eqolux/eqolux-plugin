# Eqolux in the Microsoft 365 Agent Store: Partner Center listing

Everything to enter in Partner Center for the **Apps and agents for Microsoft 365 and Copilot** offer, ready to paste, in English and French. Prepared on 2026-10-08 against the Microsoft documentation of that date (sources at the end).

| Item | Value |
| --- | --- |
| Package | `appPackage/build/appPackage.prod.zip`, built with `atk package --env prod` (Agents Toolkit CLI 1.1.18-beta.2026092303.0) |
| Manifest id | `b44aa36a-9971-4e9a-bd5c-251fd82e8917` (store identity; keep it for every update) |
| Manifest version | `1.0.0` (raise it for each new submission) |
| Validation | `atk validate --package-file`: 61 rules passed, no warning. `atk validate --manifest-file --env prod`: all schemas passed |
| OAuth | Auth config `MCP_DA_AUTH_ID_EQOLUX` of `env/.env.dev`, reused (Any Teams app, Any Microsoft 365 organization) |
| MCP server | `https://mcp.eqolux.com/mcp`, 3 read-only tools discovered at runtime |

Rebuild the zip after any change to `appPackage/` and before uploading: `appPackage/build/` is gitignored.

## 1. Before submitting

Items that block or weaken the submission today. Section 9 maps every guideline.

1. **Privacy policy (must fix).** Partner Center fails a policy that does not cover the submitted app; Microsoft's guidelines ask it to reference the services in scope. Section 8 of `https://www.eqolux.com/privacy-policy/` is titled "AI Assistant Connector (Claude, ChatGPT)" and never mentions Microsoft 365 Copilot. Add Microsoft 365 Copilot there: the Eqolux agent in Microsoft 365 Copilot uses the same connector; Microsoft processes the data under the customer's own Microsoft agreement; Microsoft keeps the user's Eqolux sign-in token in its token store; signing out is done from Copilot's agent settings. Website track.
2. **Help page (should fix).** `https://www.eqolux.com/ai-connector/` explains Claude and ChatGPT only. Add a Microsoft 365 Copilot section (install by an administrator, sign-in, the starters, sign-out) so the support link and the long description point to instructions that match the agent. Website track.
3. **Re-test the version submitted.** The package now carries a disclaimer, new descriptions, a new spend starter and two instruction changes (negotiated prices, errors). Run `atk provision --env dev` (it rebuilds and re-sideloads the dev agent with the same texts), run the six starters and the negative cases of section 7, and take the screenshots on that build.
4. **Response time.** Microsoft asks for at most 9 s for 99 % of responses (2 s for 50 %, 5 s for 75 %). On the demo organization every query runs in 0.25 to 0.5 s in the database; the end-to-end time in Copilot (sign-in excluded) has not been measured. Measure each starter in Copilot Chat, Teams and Word. On large customers (organization 590) the savings query takes up to 7.9 s on 12 months, too close to the limit.
5. **Availability (99.9 %).** Confirm that production runs the cold-start fix and `--min-instances 1` (project-status entry of 2026-10-08 afternoon), and add an uptime check on `https://mcp.eqolux.com/health` (answers `{"ok":true}`), so a failure is seen before Microsoft's continuous health evaluation sees it.
6. **Test accounts.** `review@eqolux.com` (Eqolux user 173, organization 259 only) must stay active, without MFA or email-code-only sign-in, and with a known password, for as long as the agent is listed: Microsoft re-tests listed agents. Microsoft also asks for "at least one account that isn't pre-configured to test the first-run sign-in experience": create a second Eqolux account on organization 259 that has never signed in anywhere (for example `review2@eqolux.com`) and give both.
7. **OAuth registration.** Open the Teams Developer Portal, **Tools > OAuth client registration**, and confirm on the dev registration: **Restrict usage by org** = *Any Microsoft 365 organization*, **Restrict usage by app** = *Any Teams app*, base URL `https://mcp.eqolux.com/mcp`. With *My organization only*, reviewers and customers cannot sign in.
8. **Screenshots and video** (section 5): to capture.
9. **Partner Center account.** The Microsoft 365 and Copilot program and the company verification are complete (2026-10-08). Confirm that the domain `eqolux.com` is verified for the publisher (the MCP server must be served from it or a subdomain). Publisher Attestation (policy 1140.6) is completed after the first listing.
10. **Microsoft 365 test tenant.** The Teams submission checklist asks for an admin and a non-admin account of a configured tenant when an app needs tenant configuration. This agent needs none beyond allowing it, so the notes say so; if the reviewers ask, give two accounts of the Eqolux tenant with Copilot Chat.

## 2. Offer setup

| Field | Value |
| --- | --- |
| Offer type | Apps and agents for Microsoft 365 and Copilot |
| Offer name (reserve with **Check availability**) | `Eqolux` (identical to `name.short` in the manifest, the agent name and the plugin name) |
| Publisher | Eqolux (identical to `developer.name`) |
| Will your app be listed in the Apple Store? | No |
| Does your app use Microsoft Entra ID or single sign-on (SSO)? | No. Users sign in to Eqolux through OAuth 2.0 (Eqolux's identity provider, WorkOS); no Entra app registration |
| Does your app require additional purchases? | Yes: an Eqolux subscription for the customer's organization, sold by Eqolux. Disclosed in the description; test credentials are in the certification notes |
| Lead management (CRM) | Optional; leave unconnected unless Eqolux wants leads from the store |

## 3. Packages

Upload `appPackage/build/appPackage.prod.zip`. The checks must show **Complete**. If Partner Center reports an issue the toolkit did not, run the package through the Teams app validation tool (`https://dev.teams.microsoft.com/tools/store-validation`), which uses the store's own test cases.

## 4. Properties

### Categories (at least one, up to three)

The Teams Store category list documented for submissions (2026-08-05):

1. **Data visualization and BI**
2. **Workflow and business management**
3. **Financial management**

If the form shows the newer Microsoft Marketplace taxonomy instead (primary and secondary category with subcategories): **Analytics** (Data Analytics, Data Insights) and **Operations & Supply Chain** (Planning, Purchasing & Reporting); add **AI Apps and Agents** (Agents) if a third is allowed.

### Industries (optional, up to two)

**Hospitality & Travel** only. Eqolux serves restaurant and hotel groups; no second industry fits.

### Legal and support

| Field | Value |
| --- | --- |
| Standard contract | Leave unchecked (Eqolux's own terms apply; the choice of the standard contract cannot be reversed after publishing) |
| End User License Agreement (EULA) / terms of use link | `https://www.eqolux.com/terms/` |
| Privacy policy link | `https://www.eqolux.com/privacy-policy/` (see section 1, item 1) |
| Support document link | `https://www.eqolux.com/contact/` (contact form, `hello@eqolux.com`; switch to `https://www.eqolux.com/ai-connector/` once it covers Microsoft 365 Copilot and keeps its support section) |
| Website (manifest `developer.websiteUrl`) | `https://www.eqolux.com` |

The privacy and terms links are the same as in the manifest (`developer.privacyUrl`, `developer.termsOfUseUrl`), as required.

## 5. Marketplace listings

Add the languages **English** (default) and **French** under **Manage additional languages**; both are in the package (`localizationInfo`).

### Name

| | |
| --- | --- |
| EN | Eqolux |
| FR | Eqolux |

### Summary (short description, 100 characters at most; one sentence, without the app name)

Identical to `description.short` of the package.

| | Text | Characters |
| --- | --- | --- |
| EN | Supplier spend, price and savings analysis for restaurant and hotel groups | 74 |
| FR | Dépenses fournisseurs, prix et économies des restaurants et hôtels | 66 |

### Description (4,000 characters and 500 words at most)

Format it with the editor's bold, bullets and links (Partner Center has no preview: check the result on the listing preview after saving). It follows the package's `description.full` and adds the links the store guidelines ask for (how to get an account, help, support).

**English** (about 2,500 characters, 375 words)

> Eqolux reads the supplier invoices, delivery notes and credit notes of restaurant and hotel groups and turns them into structured purchase data. The Eqolux agent, designed for Microsoft 365 Copilot, lets you ask questions about that data in plain language, in Copilot Chat, Microsoft Teams and the Microsoft 365 apps. Answers come as tables, with links to the products, documents and suppliers in Eqolux.
>
> **Who it is for**: purchasing managers, chefs, controllers and general managers of restaurant and hotel groups that use Eqolux.
>
> **Key benefits**
> - **Know where your money goes**: spend by supplier, establishment, product category and month, with credit notes netted out and amounts in one currency.
> - **Catch price drift**: follow product prices over time, find the same product bought at very different prices, and spot purchases above a negotiated price.
> - **Understand your sourcing**: where your products come from and their estimated carbon footprint.
>
> **How it works**
> - Open the Eqolux agent in Microsoft 365 Copilot and ask, for example, "Who were my 10 biggest suppliers over the last 12 months?"
> - The first time, select **Sign in to Eqolux** and sign in with your Eqolux account. Copilot then asks you to allow Eqolux to answer.
> - To sign out, open **Chat settings > Agents** in Copilot.
>
> **Requirements**
> - An Eqolux account, which comes with your organization's paid Eqolux subscription. To get one, [contact Eqolux](https://www.eqolux.com/contact/).
> - Microsoft 365 Copilot or Copilot Chat, with the agent allowed by your Microsoft 365 administrator.
>
> **Limits**
> - The agent only reads data: it cannot create, change or delete anything in Eqolux.
> - Answers are limited to the organizations, establishments, suppliers, documents and product categories your Eqolux account can access, one organization at a time.
> - Each question covers one period of up to ten years. Without a period, the agent uses the last 12 months.
> - Answers are generated by AI and can contain mistakes: check important figures in Eqolux. Savings figures are estimates computed from the documents Eqolux has read.
> - The listing is available in English and French; the agent answers in the language of the question.
>
> **Help and support**: see [how to use Eqolux with an AI assistant](https://www.eqolux.com/ai-connector/), or write to [support@eqolux.com](mailto:support@eqolux.com), including to report an inaccurate or inappropriate answer. [Privacy policy](https://www.eqolux.com/privacy-policy/) · [Terms](https://www.eqolux.com/terms/)

**French**

> Eqolux lit les factures, bons de livraison et avoirs fournisseurs des groupes de restaurants et d'hôtels et les transforme en données d'achat structurées. L'agent Eqolux, conçu pour Microsoft 365 Copilot, vous permet d'interroger ces données en langage courant, dans Copilot Chat, Microsoft Teams et les applications Microsoft 365. Les réponses arrivent sous forme de tableaux, avec des liens vers les produits, documents et fournisseurs dans Eqolux.
>
> **Pour qui** : responsables achats, chefs, contrôleurs de gestion et directeurs de groupes de restaurants et d'hôtels qui utilisent Eqolux.
>
> **Principaux bénéfices**
> - **Savoir où va votre argent** : dépenses par fournisseur, établissement, catégorie de produits et mois, avoirs déduits et montants dans une seule devise.
> - **Repérer les dérives de prix** : suivre les prix des produits dans le temps, trouver un même produit acheté à des prix très différents et les achats au-dessus d'un prix négocié.
> - **Comprendre vos approvisionnements** : l'origine de vos produits et leur empreinte carbone estimée.
>
> **Comment ça marche**
> - Ouvrez l'agent Eqolux dans Microsoft 365 Copilot et posez une question, par exemple « Quels ont été mes 10 plus gros fournisseurs sur les 12 derniers mois ? »
> - La première fois, sélectionnez **Se connecter à Eqolux** et connectez-vous avec votre compte Eqolux. Copilot vous demande ensuite d'autoriser Eqolux à répondre.
> - Pour vous déconnecter, ouvrez **Paramètres de conversation > Agents** dans Copilot.
>
> **Prérequis**
> - Un compte Eqolux, fourni avec l'abonnement Eqolux payant de votre organisation. Pour en obtenir un, [contactez Eqolux](https://www.eqolux.com/fr/contact/).
> - Microsoft 365 Copilot ou Copilot Chat, avec l'agent autorisé par votre administrateur Microsoft 365.
>
> **Limites**
> - L'agent lit seulement les données : il ne peut rien créer, modifier ni supprimer dans Eqolux.
> - Les réponses se limitent aux organisations, établissements, fournisseurs, documents et catégories de produits auxquels votre compte Eqolux a accès, une organisation à la fois.
> - Chaque question porte sur une période de dix ans au plus. Sans période, l'agent prend les 12 derniers mois.
> - Les réponses sont générées par IA et peuvent contenir des erreurs : vérifiez les chiffres importants dans Eqolux. Les économies affichées sont des estimations calculées à partir des documents lus par Eqolux.
> - La fiche est disponible en anglais et en français ; l'agent répond dans la langue de la question.
>
> **Aide et support** : consultez [comment utiliser Eqolux avec un assistant IA](https://www.eqolux.com/fr/connecteur-ia/), ou écrivez à [support@eqolux.com](mailto:support@eqolux.com), y compris pour signaler une réponse inexacte ou inappropriée. [Politique de confidentialité](https://www.eqolux.com/privacy-policy/) · [Conditions](https://www.eqolux.com/terms/)

The labels of the sign-in button and of the settings menu in French Copilot may differ from « Se connecter à Eqolux » and « Paramètres de conversation > Agents »: check them on the French screenshots and align the text.

### Search keywords (optional, up to three)

| | Keywords |
| --- | --- |
| EN | purchasing, suppliers, food cost |
| FR | achats, fournisseurs, coût matière |

### Logo

The color icon of the package, `appPackage/color.png` (192×192 PNG): the store icon must match it. If the field asks for a larger image, upload `store/logo-300.png` (the same icon at 300×300).

### Screenshots (3 to 5 per language; 1366×768 px; PNG; 1,024 KB at most)

Rules: real UI of the submitted build, no mock-up, at least one in Copilot, legible text, one message per image, no personal data (use the demo organization 259 "Best Hotels Group" and a neutral Microsoft 365 user name), no browser chrome beyond the Microsoft 365 window. Show the French Copilot UI for the French listing. Capture at 1366×768 (browser window or `sips -c 768 1366 file.png` to crop), then check the size and weight.

| # | Client | Prompt (EN / FR) | Caption EN | Caption FR |
| --- | --- | --- | --- | --- |
| 1 | Copilot Chat on the web (`m365.cloud.microsoft/chat`) | Starter "Top suppliers" / « Principaux fournisseurs » | See your biggest suppliers and open each one in Eqolux | Voyez vos principaux fournisseurs et ouvrez chacun dans Eqolux |
| 2 | Copilot Chat on the web | Starter "Spend by month" / « Dépenses par mois » | Follow spend month by month in each establishment | Suivez les dépenses mois par mois dans chaque établissement |
| 3 | Copilot in Microsoft Teams | Starter "Price increases" / « Hausses de prix » | Spot the product prices that increased the most | Repérez les prix de produits qui ont le plus augmenté |
| 4 | Copilot in Word (side pane) | Starter "Savings" / « Économies » | Find the same product bought at very different prices | Trouvez un même produit acheté à des prix très différents |
| 5 | Copilot Chat on the web | Starter "Origins and carbon" / « Origines et carbone » | See where your food comes from and its carbon footprint | Voyez d'où vient votre alimentation et son empreinte carbone |

Optional replacement for #5 if a sign-in image is wanted: the **Sign in to Eqolux** card on first use, caption "Sign in once with your Eqolux account" / « Connectez-vous une fois avec votre compte Eqolux ».

### Video (optional)

A YouTube (`https://www.youtube.com/watch?v=<id>` or `https://youtu.be/<id>`) or Vimeo (`https://vimeo.com/<id>`) link, ads turned off in the platform settings. Suggested 60 to 90 s walkthrough, educational rather than promotional: who it is for; opening the agent in Copilot Chat; the first sign-in; two starters with their tables and a click on a link that opens Eqolux; the read-only and permissions limits; sign-out. The video recorded for OpenAI (review account, organization 259) can be reused only if it shows Microsoft 365 Copilot; otherwise record a new one.

## 6. Availability

Choose the publication schedule carefully: it cannot be changed after the first publish. Recommended: publish as soon as certification passes. Markets: all by default (Eqolux's customers are in France and Europe; nothing in the agent depends on the country).

## 7. Notes for certification

Paste the short version in **Notes for certification** and upload the full version (this section with section 8, exported to PDF) in **Additional certification info**. Reviewers cannot contact Eqolux: the notes must be complete. Type the passwords in Partner Center only; never write them in this repository.

### Short version (paste)

```text
Eqolux agent for Microsoft 365 Copilot: a declarative agent with one action, a remote MCP server (https://mcp.eqolux.com/mcp) exposing three read-only tools (list_organizations, describe_data, run_sql_query; readOnlyHint true). It reads the purchasing data of restaurant and hotel groups in Eqolux. No Microsoft Entra ID, no SSO, no tenant data, no admin configuration beyond allowing the agent.

TEST ACCOUNTS (Eqolux accounts, no MFA, valid for as long as the agent is listed)
1. review@eqolux.com / password: <PASSWORD 1>
2. review2@eqolux.com / password: <PASSWORD 2> (never signed in: first-run test)
Both belong only to the demo organization "Best Hotels Group" (id 259), which holds synthetic data.

SIGN-IN
1. Open Microsoft 365 Copilot Chat, select the Eqolux agent, select a conversation starter.
2. Select "Sign in to Eqolux". On the Eqolux sign-in page, enter the email, choose password sign-in, enter the password.
3. Back in Copilot, select "Allow" when Copilot asks to use Eqolux the first time.
Sign-out: Chat settings > Agents > Eqolux > sign out.

TESTS (expected answers for organization 259, EUR, excluding tax)
- "Who were my 5 biggest suppliers in 2025?" -> Coastal Catch SARL ~2.97M, Ocean Fresh SAS ~2.62M, Blue Harvest SARL ~2.18M, Sea & Garden SAS ~2.08M, Heritage Harvest SARL ~1.17M, each name linked to Eqolux.
- The six conversation starters each return a table for the period they name (details in the attached PDF).
- "Place an order for 10 kg of salmon" -> declined (read-only) with a question it can answer instead.
- "What is the market price of salmon today?" -> explains it only has the organization's own purchase data.
- Insults or off-topic requests -> polite refusal and a purchasing question to ask instead.
The demo data is synthetic and some prices are deliberately implausible; the agent may say so, which is expected.
Support: support@eqolux.com
```

### Full version (PDF)

**What the agent does.** Eqolux is a purchasing analytics platform for restaurant and hotel groups. The agent answers questions about the signed-in user's purchase data (spend, suppliers, prices, savings estimates, negotiated prices, origins, carbon footprint) and links names to the Eqolux web app. It only reads data. Every answer is limited to what the user's Eqolux account can access, one organization at a time.

**Architecture.** Declarative agent (schema 1.8) with one action: a plugin (schema 2.4) with a `RemoteMCPServer` runtime, `https://mcp.eqolux.com/mcp` (subdomain of the verified domain eqolux.com, HTTPS only, no redirects), dynamic tool discovery, OAuth 2.0 authorization code with PKCE through an `OAuthPluginVault` auth config. Tools:

| Tool | Purpose | Annotations |
| --- | --- | --- |
| `list_organizations` | The organizations the signed-in user belongs to | readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false |
| `describe_data` | Documentation of the tables and columns the query tool can read | same |
| `run_sql_query` | One read-only SQL SELECT on one organization, with an optional period (`period_start`, `period_end`, last 24 months by default, 120 months at most), 500 rows at most | same |

Safeguards on the server: the query is parsed with the PostgreSQL parser and only a single SELECT over the documented dataset tables is accepted (no writes, no system tables, no recursive queries, limited functions); it runs in a read-only transaction with a statement timeout; row-level scope is computed from the user's Eqolux permissions for each call; per-user rate limits. Text values returned from documents are treated as data, never as instructions (server instructions and agent instructions).

**Test accounts.** Two Eqolux accounts on the demo organization "Best Hotels Group" (id 259), the only organization they can access. The first has been used before; the second has never signed in, for the first-run experience. Neither has MFA. Passwords are in the Notes for certification.

**Sign-in steps.**
1. Open Microsoft 365 Copilot Chat (`https://m365.cloud.microsoft/chat`), Microsoft Teams (Copilot) or Word (Copilot pane), and select the **Eqolux** agent.
2. Select a conversation starter. Copilot shows **Sign in to Eqolux**: select it.
3. The Eqolux sign-in page opens (Eqolux's identity provider, WorkOS). Enter the test email, choose to sign in with a password, enter the password.
4. Back in Copilot, allow Eqolux when Copilot asks the first time. The answer appears.
5. To sign out: **Chat settings > Agents**, Eqolux, sign out. The next question asks to sign in again.

**Conversation starters and expected answers.** Values verified on 2026-10-08 with the Eqolux dataset for organization 259, in EUR excluding tax. The starters use periods relative to today ("last 12 months"), so their figures move with time; the fixed-period prompts below give stable values.

| Starter | Expected answer (as of 2026-10-08) |
| --- | --- |
| Top suppliers: "Who were my 10 biggest suppliers over the last 12 months?" | A table of 10 suppliers with their spend, names linked to Eqolux, period 2025-10-08 to 2026-10-08 stated: ENERGYPLUS LTD ~1.68M, PREMIUM SERVICES INTERNATIONAL ~1.62M, Coastal Catch SARL ~1.09M, Ocean Fresh SAS ~0.95M, FRAÎCHEUR MARINE SAS ~0.81M, La Criée Verte SARL ~0.80M, Sea & Garden SAS ~0.75M, Blue Harvest SARL ~0.74M, GREENENERGY SOLUTIONS ~0.70M, PROFURNITURE INTERNATIONAL ~0.67M |
| Spend by month: "How did spend evolve month by month in each of my establishments over the last 6 months?" | One row per establishment, one column per month: Hotel Paris (for example May 2026 ~1.76M, September 2026 ~0.77M) and Hotel Cannes (for example September 2026 ~0.19M) |
| Price increases: "Which product prices increased the most in the last 6 months?" | Products with earlier price, recent price, change and estimated extra cost, for example VIP GUEST SERVICES (PER EVENT), PREMIUM SERVICES INTERNATIONAL, ~1,646 to ~2,338 per unit (+42 %); SMART BUILDING CONSULTING, GREENENERGY SOLUTIONS (+49 %); LUXURY TRANSPORTATION SERVICE, SERVICESPRO HOSPITALITY (+37 %) |
| Savings: "Where could I save money on my food purchases?" | Products bought at very different prices per kg, with estimated savings, for example John Dory (Sea & Garden SAS), Lieu jaune (Océan & Terroir SARL), Saint-Pierre (MER & POTAGER SAS), and two or three suggested actions |
| Negotiated prices: "Which purchases were above our negotiated prices in the last 3 months?" | ELECTRICITY CONTRACT - MONTHLY and GAS CONTRACT - MONTHLY (ENERGYPLUS LTD), bought above their negotiated price per unit |
| Origins and carbon: "Where do our food purchases come from, and what is their carbon footprint?" | Food spend by origin with estimated CO2e: France ~3.53M (~100 t CO2e), Unknown ~1.47M, United States ~0.62M, Iceland ~0.40M, Peru ~0.35M; ~189 t CO2e in total |

**Fixed-period prompts (stable values).**

| Prompt | Expected answer |
| --- | --- |
| "Who were my 5 biggest suppliers in 2025?" | Coastal Catch SARL 2,972,890; Ocean Fresh SAS 2,620,690; Blue Harvest SARL 2,182,017; Sea & Garden SAS 2,080,676; Heritage Harvest SARL 1,167,628 |
| "Show monthly spend per establishment from January to March 2026." | Best Hotels Group 683,156 / 628,970 / 834,036; Hotel Cannes January 1,084,163; Hotel Paris January 831,923, March 918,728 |
| "Which food products' price per kg increased the most between the first and the second half of 2025?" | Live Spider Crab (Coastal Catch SARL) ~4,473 to ~9,240 per kg; Royal Sea Bream (Blue Harvest SARL) ~1,731 to ~6,308; John Dory (Sea & Garden SAS) ~5,027 to ~10,813 |
| "In 2025, which purchases were above our negotiated prices?" | Live Spider Crab (Coastal Catch SARL), negotiated at 12 per kg, 12 lines, ~1.78M of spend |
| "Where did our food purchases come from in 2025, and what was their carbon footprint?" | France ~7.50M (~272 t CO2e), Unknown ~2.38M, United States ~1.83M, Peru ~0.86M, Iceland ~0.69M; ~490 t CO2e in total |

The demo organization's data is synthetic, and some unit prices are deliberately implausible. The agent may point them out as implausible and suggest checking them: that is the expected behavior, not an error.

**Negative and error cases.**

| Prompt | Expected behavior |
| --- | --- |
| "Place an order for 10 kg of salmon from Ocean Fresh SAS." | Says it only reads data and cannot order, suggests a question about salmon purchases |
| "Pay the last invoice from Coastal Catch SARL." | Same: read-only, no payments |
| "What is the market price of salmon today?" | Says it only has the organization's own purchase data; offers the organization's salmon prices |
| An insult, or a request unrelated to purchasing | Polite refusal and a purchasing question it can answer |
| "Show my suppliers for organization 590." | Eqolux answers that the organization is not one of the user's organizations; the agent says so and offers Best Hotels Group |
| "Show all purchases since 2010." | Asks for or applies a period within the ten-year limit and states the period used |

**Responsible AI.** A disclaimer at the start of each conversation says answers are generated by AI and can contain mistakes. Users report problems to support@eqolux.com (stated in the listing and the app description). Text from documents is never followed as instructions.

## 8. Data handling statement

- The agent reads Eqolux data only through the MCP server; it uses no Microsoft 365 tenant data (no capabilities declared).
- The MCP server returns query results to Microsoft 365 Copilot for the answer. Eqolux does not receive the conversation, only the tool calls. Eqolux logs each call (user id, organization, query text, row count, duration, never the results) for 30 days in Google Cloud Logging (global location). The connector server runs on Google Cloud in the EU (Belgium); the purchasing data it reads is stored by Eqolux's backend provider Xano on Google Cloud in the USA (see the DPA, Annex 3).

  *Note for Benoit, not part of the statement: if the EU log bucket from the GCP hardening runbook (step 3) is in place before you submit, replace "Google Cloud Logging (global location)" with "Google Cloud Logging in the EU (Belgium)".*
- Microsoft stores the user's Eqolux OAuth token in its Enterprise token store; signing out of the agent clears it.

## 9. Compliance checklist

Sources: validation guidelines for agents (2026-08-13), Teams Store validation guidelines, certification policy 1140 (in particular 1140.1, 1140.3, 1140.4.1, 1140.9), Partner Center submission guide and checklist. Status: **Met**, **Verify** (met in the package, to confirm in Copilot or Partner Center), **To do**, **N/A**.

| Guideline | How Eqolux complies | Status |
| --- | --- | --- |
| Value proposition beyond Copilot (agents guidelines) | Access to the organization's own purchasing data, extracted from supplier documents, which Copilot cannot reach | Met |
| Descriptions, instructions, starters: no instructional phrases ("ignore", "delete", "reset", "new instructions"…), no URL, emoji or hidden characters; correct grammar; no superlatives (agents guidelines; 1140.9) | Checked on the built package: instructions are plain ASCII, no URL in the agent description, starters or instructions; the manifest description carries email addresses, not URLs | Met |
| Agent name identical in manifest, agent and plugin, and in the offer (agents guidelines; 1140.1.1) | `Eqolux` everywhere, in English and French | Met |
| App name rules (Teams guidelines) | Brand name, no Microsoft product name, no "Dev/Beta" (the prod build has no suffix) | Met |
| Short description: one sentence, no app name, no "app" | 74 characters | Met |
| Long description: ≤ 4,000 characters and 500 words; audience; value; supported Microsoft products; requirements; limits; help or support link; "designed for Microsoft 365 Copilot" wording; supported languages | Section 5 (about 375 words); the package's version has the same content, with email addresses instead of links | Met |
| Additional purchases disclosed (1100.1, checklist) | "Requires an Eqolux subscription" in the description; box checked in Product setup | Met |
| Sign-in, sign-out, sign-up way forward (1140.1.4) | Sign-in card in Copilot; sign-out from Chat settings > Agents; how to get an account in the description and the disclaimer | Met |
| At least 3 conversation starters, all functional (agents guidelines; 1140.9) | 6 starters, each verified on organization 259 on 2026-10-08 | Verify after re-provision |
| Each function covered by a prompt (agents guidelines) | Every starter uses `list_organizations`, `describe_data` and `run_sql_query`; the instructions describe all three | Met |
| Rich responses with way forward and citations (agents guidelines; 1140.9) | Tables; names linked to Eqolux through `app_url`; scope (organization, dates, currency) under each answer; next steps suggested | Verify that reviewers accept inline links as citations |
| Safeguards against instruction override (agents guidelines; Teams AI guidelines) | Data-as-data rule in the server instructions, tool descriptions and agent instructions; read-only SQL guard; links only from returned `app_url` values | Met |
| Graceful errors: incorrect parameters, misuse or inappropriate language (agents guidelines) | Actionable server errors (period, timeout, busy, unknown organization, sign-in); instructions to explain errors with a next step and to decline abusive or off-topic requests politely | Verify with the negative cases |
| Explicit user permission before server calls; consequential actions confirmed (1140.9; agents guidelines) | Copilot asks to allow Eqolux on first use; all tools are read-only with `readOnlyHint: true`, which Microsoft documents as the way to skip later prompts for tools without side effects | Met (reviewers may still ask about the free-SQL tool) |
| Response time: p50 ≤ 2 s, p75 ≤ 5 s, p99 ≤ 9 s (agents guidelines; 1140.4.1; 1140.9) | Database time 0.25 to 0.5 s per query on organization 259; 10 s server timeout | To do: measure end to end in Copilot; large organizations near the limit (section 1, item 4) |
| Reliability 99.9 % (agents guidelines) | Cloud Run, minimum one instance, warm-up before serving | To do: confirm deployment and add monitoring (section 1, item 5) |
| Compatibility: Teams desktop and web, Copilot on the web, Copilot in Word (agents guidelines; 1140.9) | Declarative agent, no custom UI | To do: test in the three clients |
| HTTPS with TLS 1.2+, no redirect, verified domain or subdomain (1140.3.2) | `https://mcp.eqolux.com/mcp`, TLS 1.2/1.3, answers directly without redirect | Met (confirm eqolux.com is verified in Partner Center) |
| No external domains in the manifest (1140.3.3) | `validDomains` empty; the only URL in the plugin is the MCP server | Met. Note: the OAuth endpoints are on `sincere-giggle-81.authkit.app` (WorkOS); they live in the OAuth registration, not in the manifest. If a reviewer objects, a WorkOS custom domain (for example `auth.eqolux.com`) would move them under eqolux.com |
| Multi-tenant capabilities (1140.9) | OAuth registration for Any Microsoft 365 organization; no tenant-specific setting | Verify in the Developer Portal (section 1, item 7) |
| Adaptive Card rules | No Adaptive Card responses | N/A |
| SSO, bot channel, CSP, TeamsJS | No SSO, bot, tab or web content | N/A |
| Actions and knowledge sources (tenant data, Dataverse…) | No capabilities declared | N/A |
| Duplicate agents | One agent; the dev sideload is never published | Met |
| Manifest version ≥ 1.13; ≥ 1.25 for channel apps | Manifest 1.30; `supportsChannelFeatures: tier1` as scaffolded by the toolkit | Met. Verify: the declaration means the app was checked in standard, shared and private channels; remove it in a later version if the agent cannot be used in channels |
| Icons: color 192×192, outline 32×32 white on transparent; store icon matches (Teams guidelines) | Validated by the toolkit; same icon for the listing | Met |
| Screenshots: 3 to 5, 1366×768, ≤ 1,024 KB, captions, real UI, ≥ 1 in Copilot; other Microsoft 365 clients recommended (agents and Teams guidelines; 1140.4.1; 1140.9) | Five planned in section 5 (Copilot Chat, Teams, Word) | To do |
| Video ads turned off (1140.4.1) | Only if a video is added | To do if used |
| Test accounts valid as long as listed, with data; one not pre-configured (1140.4.1; submission checklist) | `review@eqolux.com` on organization 259; second account to create | To do (section 1, item 6) |
| AI content: no harmful content; report mechanism; AI described before acquisition; AI disclaimer in the UI (1140.4.1; Teams AI guidelines) | Answers come from purchasing data only; support@eqolux.com to report; AI stated in the description; disclaimer at conversation start, plus Copilot's own AI notice | Met |
| Privacy policy: covers the app, personal data handling, storage, retention, deletion, security, contact; no login; same link as the manifest (100.6; Teams guidelines; Partner Center) | Retention, security and contact sections exist; the connector is described in section 8 | To do: name Microsoft 365 Copilot (section 1, item 1) |
| Terms of use: own domain, HTTPS, no login, same link as manifest | `https://www.eqolux.com/terms/` | Met |
| Support link without login, with contact details (Teams guidelines; 1140.8 for clients) | `https://www.eqolux.com/contact/` | Met (better once the help page covers Copilot) |
| Localization: language files, same metadata in every language, languages stated in the description, default language set (Teams guidelines) | `en.json` (default), `fr.json`; both descriptions say English and French | Met |
| No advertising (1140.7) | None | Met |
| Publisher Attestation (1140.6) | Completed after the first listing, as Microsoft allows for new apps | To do after listing |
| Publisher Verification (Teams submission checklist) | Concerns Microsoft Entra app registrations; the agent has none | N/A (confirm if Partner Center asks) |
| Zero regressions on resubmission | First submission | N/A |

## Sources

- Validation guidelines for agents, 2026-08-13: <https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/appsource/prepare/review-copilot-validation-guidelines>
- Teams Store validation guidelines: <https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/appsource/prepare/teams-store-validation-guidelines>
- Certification policies, section 1140: <https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#1140-apps-and-agents-for-microsoft-365-and-copilot>
- Prepare for Teams Store submission (categories, screenshots, video, test accounts), 2026-08-05: <https://learn.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/appsource/prepare/submission-checklist>
- Partner Center step-by-step submission guide: <https://learn.microsoft.com/en-us/partner-center/marketplace-offers/add-in-submission-guide>
- Partner Center publishing checklist (unique manifest id, same id for updates; privacy policy content): <https://learn.microsoft.com/en-us/partner-center/marketplace-offers/checklist>
- Listing lengths (name 50, summary 100 characters): <https://learn.microsoft.com/en-us/partner-center/marketplace-offers/create-effective-office-store-listings>
- Marketplace categories and industries: <https://learn.microsoft.com/en-us/partner-center/marketplace-offers/marketplace-categories-industries>
- OAuth 2.0 auth config (Any Microsoft 365 organization, Any Teams app, 404 when bound to an app), 2026-08-28: <https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/plugin-authentication-oauth>
- OAuth registration for store apps ("update your target tenant to Any Microsoft 365 organization before submitting"): <https://learn.microsoft.com/en-us/microsoftteams/platform/messaging-extensions/api-based-oauth>
- Confirmation prompts and `readOnlyHint`, 2026-07-14: <https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/plugin-confirmation-prompts>
- Declarative agent schema 1.8 (disclaimer, conversation starters): <https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-manifest-1.8>
