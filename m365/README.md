# Eqolux for Microsoft 365 Copilot

A declarative agent for Microsoft 365 Copilot that connects to the Eqolux MCP server (`https://mcp.eqolux.com/mcp`). It carries no code: the package holds manifests that point Copilot at the remote server, which keeps running where it is today. The agent's instructions are adapted from the two skills in `../skills`.

The project follows the layout Microsoft 365 Agents Toolkit generates for **Declarative Agent > Add an Action > Start with an MCP Server > OAuth (with static registration)**.

| Path | Purpose |
| --- | --- |
| `appPackage/manifest.json` | Microsoft 365 app manifest (schema 1.30): name, descriptions, icons, privacy and terms URLs, the declarative agent |
| `appPackage/declarativeAgent.json` | Declarative agent (schema v1.8): name, description, conversation starters, the action |
| `appPackage/instruction.txt` | The agent's instructions (inlined into `declarativeAgent.json` when the package is built; 8,000 characters at most) |
| `appPackage/ai-plugin.json` | Plugin (schema v2.4): `RemoteMCPServer` runtime, dynamic tool discovery, `OAuthPluginVault` auth |
| `appPackage/en.json`, `appPackage/fr.json` | Store texts and localized agent strings (English default, French) |
| `appPackage/color.png`, `appPackage/outline.png` | Icons, 192×192 and 32×32 |
| `m365agents.yml` | Lifecycle: provision (app, OAuth registration, package, validation, sideload) and publish to a tenant catalog |
| `env/.env.dev`, `env/.env.prod` | Environment values (committed, no secrets). Secrets go in `env/.env.<env>.user`, which is gitignored. `dev` is provisioned (sideload); `prod` is only packaged for the store |
| `STORE_LISTING.md` | Partner Center listing (EN/FR), certification notes, screenshot list, compliance checklist |
| `store/logo-300.png` | The color icon at 300×300, for a Partner Center logo field that asks for more than 192 px |

Tools are discovered at runtime from the server (`functions: []`, `run_for_functions: ["*"]`): a new or changed tool on the server reaches users without resubmitting the agent, after Microsoft's runtime safety checks on the changed tool.

## Prerequisites

1. **Partner Center account** for Eqolux, enrolled in the **Microsoft 365 and Copilot** program, with the company verified and the domain `eqolux.com` verified (the MCP server must be served from the verified domain or a subdomain, which `mcp.eqolux.com` is). Enroll at <https://partner.microsoft.com/dashboard/account/v3/enrollment/introduction/office> (an existing account adds the program under **Settings > Account settings > Programs**). Verification takes from a few days to a few weeks, so start it first.
2. **A Microsoft 365 tenant** controlled by Eqolux where **Custom App Upload** and **Copilot Access** are enabled for the developer account (Agents Toolkit shows both under the signed-in account). Copilot Chat, included with business Microsoft 365 plans, is enough to run the agent.
3. **Microsoft 365 Agents Toolkit**: the VS Code extension (6.12.0 or later) or the CLI, `npm install -g @microsoft/m365agentstoolkit-cli` (command `atk`). CLI 1.1.17 bundles an outdated plugin schema and reports three false errors on any `RemoteMCPServer` runtime (`/runtimes/0/spec must match exactly one schema in oneOf`); 1.1.18 (beta at the time of writing) and the published schema accept the manifest.
4. **A static OAuth client in WorkOS AuthKit**, dedicated to Microsoft 365 Copilot. Microsoft does not support dynamic client registration without a client secret, so the client must be created by hand:
   - redirect URI `https://teams.microsoft.com/api/platform/v1.0/oAuthRedirect` (the only one);
   - grant types authorization code and refresh token, with PKCE (S256);
   - preferably a public client, so no secret exists; otherwise a confidential client whose secret goes in `env/.env.<env>.user`;
   - scopes `openid profile email offline_access` (`offline_access` gives Copilot a refresh token);
   - Copilot sends no `resource` parameter, so AuthKit gives these tokens the environment client ID as audience. The server accepts that audience only for the client IDs listed in its `AUTHKIT_STATIC_CLIENT_IDS` setting: add the new client's ID there (see the server README).

   Eqolux's client is the WorkOS Connect app "Microsoft", `client_01M4D71QKRQJYE0MMF17KVHS35` (public, PKCE), already set in `env/.env.dev` and `env/.env.prod`.

## Configure

In `env/.env.dev`, set `MCP_DA_OAUTH_CLIENT_ID_EQOLUX` to the AuthKit client id and leave `TEAMS_APP_ID` and `MCP_DA_AUTH_ID_EQOLUX` empty: provisioning fills them. `env/.env.prod` is filled by hand (see "Package for the store").

With a public client (recommended) there is no secret and no `env/.env.<env>.user` file. With a confidential client, add `clientSecret: ${{SECRET_MCP_DA_OAUTH_CLIENT_SECRET_EQOLUX}}` to the `oauth/register` action in `m365agents.yml` and create `env/.env.dev.user` (gitignored) with a non-empty value:

```
SECRET_MCP_DA_OAUTH_CLIENT_SECRET_EQOLUX=<secret>
```

## Provision, sideload and test

```bash
cd m365
atk auth login m365
atk provision --env dev
```

Provisioning creates the app in the Teams Developer Portal, registers the OAuth client in the Microsoft Enterprise token store (`oauth/register`, writing the auth config id to `MCP_DA_AUTH_ID_EQOLUX`), builds `appPackage/build/appPackage.dev.zip`, validates it, and sideloads the agent for the signed-in account. The OAuth registration is created once per environment; to change it later, use `oauth/update` or the Teams Developer Portal (**Tools > OAuth client registration**), and keep **Restrict usage by org** on *Any Microsoft 365 organization* and **Restrict usage by app** on *Any Teams app* (a registration bound to one Teams app makes every tool call fail with a 404).

Then open <https://m365.cloud.microsoft/chat>, pick **Eqolux** under **Agents**, and:

1. run each conversation starter; on the first one, select **Sign in to Eqolux** and sign in with an Eqolux account;
2. check that answers state the organization, the exact dates and the currency, and that names link to the Eqolux app;
3. try an error case (an unknown product, a request outside purchasing data) and a long period on a large organization;
4. test in Copilot Chat on the web, in Microsoft Teams and in Word, the three clients the store review uses;
5. sign out from **Chat settings > Agents** and sign in again.

Test also with a user who has no Microsoft 365 Copilot license, to confirm what Copilot Chat alone allows before promising it to customers.

## Package for the store

The `prod` environment is **packaged, never provisioned**. `env/.env.prod` already holds everything the package needs:

- `TEAMS_APP_ID` = `b44aa36a-9971-4e9a-bd5c-251fd82e8917`, a GUID generated for the store on 2026-10-08. It is the agent's identity in the store: keep it for every future submission (Partner Center requires the same manifest id for updates). It differs from the dev app id and is not registered in the Teams Developer Portal, which the store does not require.
- `MCP_DA_AUTH_ID_EQOLUX` = the OAuth registration created by the dev provision. The registration is bound to no app and no tenant (`applicableToApps: AnyApp`, `targetAudience: AnyTenant` in `m365agents.yml`, shown in the Developer Portal as **Any Teams app** and **Any Microsoft 365 organization**), so the dev agent and the store agent share it. Consequences: a change to it (`oauth/update`, Developer Portal) affects the store agent too, and it must never be restricted to one app (every tool call would fail with a 404) or to the Eqolux organization (sign-in would fail in customer tenants).

```bash
atk package --env prod          # builds appPackage/build/appPackage.prod.zip
atk validate --package-file ./appPackage/build/appPackage.prod.zip   # validation rules (61 checks)
atk validate --manifest-file ./appPackage/manifest.json --env prod   # JSON schemas
```

Do not run `atk provision --env prod`: it would create a second Developer Portal app and sideload a second "Eqolux" agent in the Eqolux tenant. To try a change before submitting, provision `dev` again (same texts, dev app id) and test there.

Always submit the zip built by the toolkit: it inlines `instruction.txt` and resolves the `${{...}}` placeholders, so a zip made by hand from `appPackage/` is invalid. Increase `version` in `appPackage/manifest.json` for every new submission (1.0.0 for the first one). `appPackage/build/` is gitignored: rebuild the zip from the committed sources.

`atk publish --env <env>` publishes to the tenant's own app catalog: use it for an organization pilot before the store listing exists. A customer administrator can also upload the zip as a custom app in their own tenant.

## Submit in Partner Center

Every field, ready to paste in English and French, with the certification notes, the screenshot list and the compliance checklist: [`STORE_LISTING.md`](STORE_LISTING.md). In short:

1. Sign in to Partner Center: <https://partner.microsoft.com/dashboard/v2/home>.
2. **Marketplace offers > Microsoft 365 and Copilot > + New offer > Apps and agents for Microsoft 365 and Copilot**. Name the offer **Eqolux** (identical to the manifest) under the Eqolux publisher (its name must match `developer.name`, Eqolux).
3. **Product setup**: no Microsoft Entra ID or single sign-on; additional purchase required (an Eqolux subscription).
4. **Packages**: upload `appPackage.prod.zip`; the manifest checks must show **Complete**.
5. **Properties**: up to three categories and up to two industries (see `STORE_LISTING.md`), and the links: terms `https://www.eqolux.com/terms/`, privacy `https://www.eqolux.com/privacy-policy/` (the policy must name the Eqolux agent and describe how personal data is handled), support `https://www.eqolux.com/contact/`.
6. **Marketplace listings**: English and French, the 192×192 icon (`store/logo-300.png` if a larger logo is asked), three to five screenshots of which at least one shows the agent in Copilot, and an optional demo video.
7. **Availability**: choose the date carefully; the schedule option cannot change after the first publish.
8. **Notes for certification** (a submission without clear instructions fails automatically, and reviewers cannot contact you): the test account email and password of a long-lived Eqolux demo account on a demo organization, valid for as long as the agent is listed; the sign-in steps; each conversation starter with the kind of answer expected; a statement that every tool is read-only (`readOnlyHint: true`) and limited to the signed-in user's Eqolux permissions.
9. **Review and publish**. Expect a first answer within three to four business days and four to six weeks in total, often with several resubmissions.

After approval nothing is deployed automatically: a customer administrator allows agents from external publishers and deploys Eqolux from the Microsoft 365 admin center (**Agents > All agents**).

## Validation checklist

- [ ] The app name, the agent name and the plugin name are identical (Eqolux), in every language, and match the Partner Center offer.
- [ ] Short description of 80 characters at most, without the app name; full description of 500 words at most, with bullet points, the audience, the requirements (an Eqolux account) and the limits.
- [ ] No URL, emoji, superlative or instruction-like phrase in the descriptions, the conversation starters or the instructions.
- [ ] At least three conversation starters (six today), each one returning a real answer with the demo account.
- [ ] Response time: at most 2 s for 50 % of calls, 5 s for 75 % and 9 s for 99 %; 99.9 % availability. Measure end to end in Copilot; the server SQL timeout must leave room under 9 s.
- [ ] Every server call over HTTPS (TLS 1.2 or later), without redirects, from `eqolux.com` or a subdomain.
- [ ] Graceful errors: an unknown product, a period that is too long, a busy server or a request outside purchasing data each get a clear answer and a way forward.
- [ ] Answers cite their sources: names linked to the Eqolux app through `app_url`.
- [ ] Icons: color 192×192, outline 32×32 white on transparent without padding; the Partner Center icon matches the color icon.
- [ ] The test account in the certification notes works, and keeps working while the agent is listed.
- [ ] Privacy policy and terms reachable and naming the agent; support page reachable.

## Open points

- WorkOS AuthKit: the static client exists (Connect app "Microsoft") and the server accepts its tokens' environment audience; confirm end to end with the first sideloaded sign-in.
- Store policy 1140.9 asks for explicit user permission before any server call. Copilot asks the user to allow Eqolux the first time the agent uses it; after that, tools marked `readOnlyHint: true` (all three) run without a prompt, which Microsoft documents as the expected behavior for read-only tools. A tool taking free SQL may still draw questions from reviewers.
- Copilot Chat without a Microsoft 365 Copilot license: Microsoft's pages disagree on whether third-party agents with custom actions are available; settle it with the test above.
