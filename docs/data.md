# Data registry
Every directory under data/ and every table under metadata/ is described here. If it is not in
this file, it is not project data. Paths are relative to the project root; the absolute root is in
config/paths.yaml.

## Data directories
| path | contents | source / provenance | produced by | batch scope |
|---|---|---|---|---|
| data/ | | | | |

Batch scope: `single` (files belong to one batch; directory is named for it) or `cumulative`
(all batches to date).

## Batches
| batch | date | libraries | pipeline version | status | notes |
|---|---|---|---|---|---|

## Metadata tables

### metadata/animals.tsv — one row per animal · key: `animal_id`
| column | type | meaning |
|---|---|---|
| animal_id | string | unique animal identifier |
| species | string | |
| sex | M / F | |
| age | number; unit stated in notes or a separate column | |
| treatment | string | condition or intervention; `none` if none |
| notes | string | |

### metadata/libraries.tsv — one row per library · key: `library_id` · joins animals on `animal_id`
| column | type | meaning |
|---|---|---|
| library_id | string | unique library identifier; matches alignment output directory name |
| animal_id | string | foreign key to animals.tsv |
| region | string | dissection region |
| assay | string | e.g. snRNA, snATAC, multiome |
| batch | string | sequencing / alignment batch id |
| library_date | ISO date | |
| index | string | optional |
| notes | string | |

Add project-specific tables below in the same column-dictionary format.
