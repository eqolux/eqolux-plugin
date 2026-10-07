# Eqolux

Analyze your restaurant and hotel purchasing data from [Eqolux](https://www.eqolux.com) in a conversation: spend by supplier, establishment and category, product prices and how they evolve, savings opportunities, origins and carbon footprint.

Eqolux reads supplier invoices, delivery notes and credit notes and turns them into structured purchase data. This plugin connects your Eqolux account and adds two skills that know how to read that data correctly.

## What's included

- **Eqolux connector** (`https://mcp.eqolux.com/mcp`): read-only access to your purchasing data, through three tools: `list_organizations`, `describe_data` and `run_sql_query`.
- **Purchasing analysis skill**: spend by supplier, establishment, category or month, product prices and their evolution, origins, carbon footprint.
- **Savings opportunities skill**: the same product bought at very different prices, price increases, purchases above a negotiated price.

## Use it

1. Install the plugin, then connect the Eqolux connector and sign in with your Eqolux account.
2. Ask, for example:
   - "Who were my 10 biggest suppliers over the last 12 months?"
   - "How did spend evolve month by month in each of my hotels this year?"
   - "Which product prices increased the most in the last 6 months?"
   - "Where could I save money on my food purchases?"

Answers link to the products, documents and suppliers in the Eqolux app.

## Data

- The connector only reads data. It cannot create, change or delete anything in Eqolux.
- Every answer is limited to the organizations, establishments, suppliers, documents and product categories your Eqolux account can access, with the same permissions as in the Eqolux app.
- Query results are sent to the AI assistant you use (Claude or ChatGPT) to answer your question. The plugin sends no data anywhere else and stores nothing itself.
- The Eqolux server keeps a technical log of each query (user, organization, query text, duration) for security and support.

See the [Eqolux privacy policy](https://www.eqolux.com/privacy-policy/) and [terms](https://www.eqolux.com/terms/).

## Support

[www.eqolux.com/contact](https://www.eqolux.com/contact/)
