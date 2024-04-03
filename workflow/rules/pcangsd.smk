
# this is a rule that will build and install pcangsd into the active conda env.
rule install_pcangsd:
    params:
        hash=config["pcangsd"]["version"],
        url=config["pcangsd"]["url"]
    output:
        flagfile=touch("results/flags/pcangsd_installed")
    conda:
        "../envs/pcangsd.yaml"
    log:
        "results/logs/install_pcangsd/log.txt"
    shell:
        "(TMP=$(mktemp -d) && cd $TMP && "
        " git clone {params.url} && "
        " cd pcangsd && "
        " git checkout {params.hash} && "
        " python setup.py build_ext --inplce && "
        " pip3 install -e . ) > {log} 2>&1 "



rule simple_pcangsd:
    input:
        flagfile="results/flags/pcangsd_installed",
        beagle="results/beagle-gl/beagle-gl.gz"
    params:
        minMaf = "{min_maf}"
    output:
        args="results/simple-pcangsd/maf_{min_maf}/{param_set}/out.args",
        cov="results/simple-pcangsd/maf_{min_maf}/{param_set}/out.cov",
        mafs="results/simple-pcangsd/maf_{min_maf}/{param_set}/out.maf.npy",
        sites="results/simple-pcangsd/maf_{min_maf}/{param_set}/out.sites"
    conda:
        "../envs/pcangsd.yaml"
    threads: 20
    resources:
        mem_mb=190000
    log:
        pcangsd="results/logs/simple_pcangsd/maf_{min_maf}/{param_set}/pcangsd_part.txt"
        beagle="results/logs/simple_pcangsd/maf_{min_maf}/{param_set}/beagle_paste_part.txt"
    shell:
        " (OUTPRE=$(dirname {output.cov})/out && "
        " pcangsd -b {input.beagle} --minMaf {params.minMaf} -t {threads} --maf_save --sites_save --selection --out $OUTPRE > {log.pcangsd} 2>&1) "