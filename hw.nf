#!/usr/bin/env nextflow

params.str = 'Hello world!'
/* above can overwritten by --str on "nextflow run" command line */

/* don't bother trying to put braces on separate lines ... not tolerated by nextflow */
process splitLetters {

    output:
    // file 'chunk_*' into chunkfiles mode flatten
    file 'chunk_*' into chunkfiles

    """
    printf '${params.str}' | split -b 6 - chunk_
    """
}

process convertToUpper {
    input:
    file x from chunkfiles.flatten()

    /* flatten is a transforming operator, and a mode?
    In any case, it just takes arrays which contain subarrays
    and flattens everything to be one array */

    output:
    stdout resultvar
    /* sets stdout to be "resultvar", the result variable. */

    """
    echo -n "nxf internal file $x: "
    cat $x | tr '[a-z]' '[A-Z]'
    """
    /* note how that command  will just send everything to stdout */
}
resultvar.println { it.trim() }
/* "it" would appear to be implicit (perhaps "item"?), and must refer to stdout
which is the output of the last process. I gather the it implicit is a string
and if we didn't use trim() then we get double newlines, because println adds
a newline by default of course */

/* this from the groovy documentation:
Implicit parameter
When a closure does not explicitly define a parameter list (using ->), a closure always defines an implicit parameter, named it. This means that this code:

def greeting = { "Hello, $it!" }
assert greeting('Patrick') == 'Hello, Patrick!'
is stricly equivalent to this one:

def greeting = { it -> "Hello, $it!" }
assert greeting('Patrick') == 'Hello, Patrick!'
*/
