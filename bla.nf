// Script parameters
params.query = "/some/data/sample.fa"
params.db = "/some/path/pdb"

db = file(params.db)

/* this a explicit naming of variable for later
use as an input */
query_ch = Channel.fromPath(params.query)

process blastSearch {
    input:
    file query from query_ch
    /* A redefinition: somewhat arguable as to whether you need this
    params.query should already be available as $query
    in all processes. 
    However $query is only a string in params, now we know it's
    a file. */

    output:
    file "top_hits.txt" into top_hits_ch

    """
    blastp -db $db -query $query -outfmt 6 > blast_result
    cat blast_result | head -n 10 | cut -f 2 > top_hits.txt
    """
    /* note simple dollarsigns are nextflow vars, for bash you need \$ */
}

process extractTopHits {
    input:
    file top_hits from top_hits_ch

    output:
    file "sequences.txt" into sequences_ch

    """
    blastdbcmd -db $db -entry_batch $top_hits > sequences.txt
    """
}
