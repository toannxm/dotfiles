# Node Size
open shards.txt
| lines
| str replace -r '\s+' ' '
| filter {|x| $x !~ '^index|^#|^$' }
| par-each {|x|
    let fields = ($x | split row ',')
    if ($fields | length) >= 8 {
        { index: $fields.0, shard: $fields.1, prirep: $fields.2, state: $fields.3, docs: ($fields.4 | into int), store: $fields.5, ip: $fields.6, node: $fields.7 }
    } else {
        null
    }
}
| filter {|x| $x != null }
| group-by node --to-table
| each {|row|
    $row
}

# Index Shading
open shards.txt
| lines
| str replace -r '\s+' ' '
| filter {|x| $x !~ '^index|^#|^$' }
| par-each {|x|
    let fields = ($x | split row ',')
    if ($fields | length) >= 8 {
        { index: $fields.0, shard: $fields.1, prirep: $fields.2, state: $fields.3, docs: ($fields.4 | into int), store: $fields.5, ip: $fields.6, node: $fields.7 }
    } else {
        null
    }
}
| filter {|x| $x.index == 'paradox_prod_ai_company_users_v2' }
| group-by node --to-table
| each {|row|
    $row.items | par-each {|item|
        $item
    }
}
| each {|item|
    { node: $item.node, index: $item.index, shard: $item.shard, prirep: $item.prirep, state: $item.state, docs: $item.docs, store: $item.store, ip: $item.ip }
}
| sort-by docs --reverse

# Node Details with Items
open shards.txt
| lines
| str replace -r '\s+' ' '
| filter {|x| $x !~ '^index|^#|^$' }
| par-each {|x|
    let fields = ($x | split row ',')
    if ($fields | length) >= 8 {
        { index: $fields.0, shard: $fields.1, prirep: $fields.2, state: $fields.3, docs: ($fields.4 | into int), store: $fields.5, ip: $fields.6, node: $fields.7 }
    } else {
        null
    }
}
| filter {|x| $x != null }
| group-by index --to-table
| each {|row|
    let docs_sum = ($row.items | get docs | math sum)
    let store_sum = (
        $row.items
        | get store
        | par-each {|s|
            if ($s | str ends-with gb) {
                $s | str replace gb '' | into float | $in * 1024 * 1024
            } else if ($s | str ends-with mb) {
                $s | str replace mb '' | into float | $in * 1024
            } else if ($s | str ends-with kb) {
                $s | str replace kb '' | into float | $in
            } else {
                # fallback: try to convert if it's just a number, else 0
                try { $s | into float } catch { 0 }
            }
        }
        | filter {|v| $v != null }
        | math sum
    )
    let 1_gb = 1024 * 1024
    let docs_sum_txt = if $docs_sum >= 1_000_000 { $"($docs_sum / 1_000_000 | math round --precision 2) M" } else if $docs_sum >= 1_000 { $"($docs_sum / 1_000 | math round --precision 2) K" } else { $"($docs_sum)" }
    let store_sum_gb = if $store_sum >= $1_gb { $"($store_sum / $1_gb | math round --precision 2) GB" } else if $store_sum >= 1024 { $"($store_sum / 1024 | math round --precision 2) MB" } else { $"($store_sum | | math round --precision 2) KB" }
    { index: $row.index, total_docs: $docs_sum_txt, total_store: $store_sum, total_store_gb: $store_sum_gb }
}
| sort-by total_store --reverse
| select index total_docs total_store_gb


open ~/Workday/MacSetup/dotfiles/shards.txt | lines | each {|line| $line | str trim -l -r | str replace -ra '\s+' ',' } | save -f ~/Workday/MacSetup/dotfiles/shards.txt
