---
trigger: model_decision
description: License policy for dependencies, models, and datasets. Activate when adding, upgrading, or evaluating any third-party package, model, or data source.
---

License policy for all dependencies, models, and datasets.

Allow-list: Apache 2.0, MIT, BSD (2-clause or 3-clause), ISC, Zlib, Unlicense, CC0.

Deny-list: GPL, AGPL, CC-BY-NC*, CC-BY-NC-ND*, Qwen Research License, Falcon Research License, Gemma Terms (legacy — Gemma 4 is Apache 2.0 and fine), Llama Community License.

CI enforces this via the license scanner. Do not disable the scanner or add exceptions without explicit user approval.