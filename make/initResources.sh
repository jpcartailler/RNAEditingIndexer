#!/usr/bin/env bash

# This work is licensed under the Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
# For use of the software by commercial entities, please inquire with Tel Aviv University at ramot@ramot.org.
# © 2019 Tel Aviv University (Erez Y. Levanon, Erez.Levanon@biu.ac.il;
# Eli Eisenberg, elieis@post.tau.ac.il;
# Shalom Hillel Roth, shalomhillel.roth@live.biu.ac.il).

RESOURCES_DIR=${1:-"../Resources"};
LIB_DIR=${2:-"../lib"};
#---------------------------------------------------------------------------
# Constants
#---------------------------------------------------------------------------
HUMAN="HomoSapiens"

HG38_FTP_URL="http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/"
HG38_FTP_GENOME_URL="http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/"

GENOME_DIR="Genomes"
HUMAN_GENOME_DIR="${RESOURCES_DIR}/${GENOME_DIR}/${HUMAN}"
HG38_GENOME_FASTA_FILE="hg38.fa.gz"
HG38_GENOME_FASTA="ucscHg38Genome.fa"

REGIONS_DIR="Regions"
HUMAN_REGIONS_DIR="${RESOURCES_DIR}/${REGIONS_DIR}/${HUMAN}"
HG38_REGIONS_FILE="ucscHg38Alu.bed.gz"
HG38_REGIONS_TABLE_FILE="rmsk.txt.gz"
#HG38_SINE_FILE="ucscHg38SINE.bed.gz"
#HG38_RE_FILE="ucscHg38AllRE.bed.gz"
#HG38_LTR_LINE_FILE="ucscHg38LINEAndLTR.bed.gz"


SNPS_DIR="SNPs"
HUMAN_SNPS_DIR="${RESOURCES_DIR}/${SNPS_DIR}/${HUMAN}"
HG38_SNPS_FILE="ucscHg38CommonGenomicSNPs150.bed.gz"
HG38_SNPS_TABLE_FILE="snp150Common.txt.gz"


REFSEQ_DIR="RefSeqAnnotations"
HUMAN_REFSEQ_DIR="${RESOURCES_DIR}/${REFSEQ_DIR}/${HUMAN}"
HG38_REFSEQ_TABLE_FILE="ncbiRefSeqCurated.txt.gz"
HG38_REFSEQ_FILE="ucscHg38RefSeqCurated.bed.gz"


GENES_EXPRESSION_DIR="GenesExpression"
HUMAN_GENES_EXPRESSION_DIR="${RESOURCES_DIR}/${GENES_EXPRESSION_DIR}/${HUMAN}"
HG38_GENES_EXPRESSION_FILE="ucscHg38GTExGeneExpression.bed.gz"
HG38_GENES_EXPRESSION_TABLE_FILE="gtexGene.txt.gz"


#---------------------------------------------------------------------------
# Downloading
#---------------------------------------------------------------------------

if [ "${DONT_DOWNLOAD}" = false ]
then

# clean folders from previous runs
find ${RESOURCES_DIR} -type f -delete

mkdir -p "${HUMAN_GENOME_DIR}"

mkdir -p "${HUMAN_REGIONS_DIR}"

mkdir -p "${HUMAN_SNPS_DIR}"

mkdir -p "${HUMAN_REFSEQ_DIR}"

mkdir -p "${HUMAN_GENES_EXPRESSION_DIR}"


echo "Started Downloading UCSC Resources."

#---------------------------------------------------------------------------
# HG38
#---------------------------------------------------------------------------

echo "Started Downloading Hg38 Files:"

# Genome
echo "Downloading Hg38 Genome: ${HG38_FTP_GENOME_URL}${HG38_GENOME_FASTA_FILE}"
wget "${HG38_FTP_GENOME_URL}${HG38_GENOME_FASTA_FILE}"  --directory-prefix="${HUMAN_GENOME_DIR}"
echo "Saving Hg38 Genome Under: ${HUMAN_GENOME_DIR}/${HG38_GENOME_FASTA}"
gunzip -c "${HUMAN_GENOME_DIR}/${HG38_GENOME_FASTA_FILE}" > "${HUMAN_GENOME_DIR}/${HG38_GENOME_FASTA}"
rm "${HUMAN_GENOME_DIR}/${HG38_GENOME_FASTA_FILE}"
echo "Done Processing Hg38 Genome"

# Repeats Regions
echo "Downloading Hg38 Alu Repeats Table ${HG38_FTP_URL}${HG38_REGIONS_TABLE_FILE}"
wget "${HG38_FTP_URL}${HG38_REGIONS_TABLE_FILE}"  --directory-prefix="${HUMAN_REGIONS_DIR}"
echo "Processing Hg38  Alu Repeats Table ${HG38_REGIONS_TABLE_FILE}"
zcat "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_TABLE_FILE}"| awk '{OFS ="\t"}($13 ~/Alu/ && $6 !~/_/) {print $6,$7,$8}' | ${BEDTOOLS_PATH} sort -i stdin| ${BEDTOOLS_PATH} merge -i stdin| gzip > "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_FILE}"
#zcat "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_TABLE_FILE}"| awk '{OFS ="\t"}($12 ~/SINE/ && $6 !~/_/) {print $6,$7,$8}' | ${BEDTOOLS_PATH} sort -i stdin| ${BEDTOOLS_PATH} merge -i stdin|  gzip > "${HUMAN_REGIONS_DIR}/${HG38_SINE_FILE}"
#zcat "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_TABLE_FILE}"| awk '{OFS ="\t"}(($12 ~/LINE/||$12 ~/LTR/) && $6 !~/_/) {print $6,$7,$8}' | ${BEDTOOLS_PATH} sort -i stdin| ${BEDTOOLS_PATH} merge -i stdin|  gzip > "${HUMAN_REGIONS_DIR}/${HG38_LTR_LINE_FILE}"
#zcat "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_TABLE_FILE}"| awk '{OFS ="\t"}($6 !~/_/) {print $6,$7,$8}' | ${BEDTOOLS_PATH} sort -i stdin| ${BEDTOOLS_PATH} merge -i stdin|  gzip > "${HUMAN_REGIONS_DIR}/${HG38_RE_FILE}"
rm "${HUMAN_REGIONS_DIR}/${HG38_REGIONS_TABLE_FILE}"
echo "Done Processing Hg38 Alu Repeats Table ${HG38_REGIONS_TABLE_FILE}"

# SNPs
echo "Downloading Hg38 Common Genomic SNPs Table ${HG38_FTP_URL}${HG38_SNPS_TABLE_FILE}"
wget "${HG38_FTP_URL}${HG38_SNPS_TABLE_FILE}"  --directory-prefix="${HUMAN_SNPS_DIR}"
echo "Processing Hg38Common Genomic SNPs Table ${HG38_SNPS_TABLE_FILE}"
zcat "${HUMAN_SNPS_DIR}/${HG38_SNPS_TABLE_FILE}" | awk '{OFS ="\t"}($11=="genomic") {print $2,$3,$4,$7,$9,$10,$16,$25}'| gzip > "${HUMAN_SNPS_DIR}/${HG38_SNPS_FILE}"
rm "${HUMAN_SNPS_DIR}/${HG38_SNPS_TABLE_FILE}"
echo "Done Processing Hg38 Common Genomic SNPs Table ${HG38_SNPS_TABLE_FILE}"

# RefSeq
echo "Downloading Hg38 RefSeq Curated Table ${HG38_FTP_URL}${HG38_REFSEQ_TABLE_FILE}"
wget "${HG38_FTP_URL}${HG38_REFSEQ_TABLE_FILE}"  --directory-prefix="${HUMAN_REFSEQ_DIR}"
echo "Processing Hg38 RefSeq Curated Table ${HG38_REFSEQ_TABLE_FILE}"
zcat "${HUMAN_REFSEQ_DIR}/${HG38_REFSEQ_TABLE_FILE}"| awk '{OFS ="\t"} {print $3,$5,$6,$2,$13,$4,$10,$11}' |gzip > "${HUMAN_REFSEQ_DIR}/${HG38_REFSEQ_FILE}"
rm "${HUMAN_REFSEQ_DIR}/${HG38_REFSEQ_TABLE_FILE}"
echo "Done Processing Hg38 RefSeq Curated Table ${HG38_REFSEQ_TABLE_FILE}"

# Genes Expression
echo "Downloading Hg38 Genes Expression Table ${HG38_FTP_URL}${HG38_GENES_EXPRESSION_TABLE_FILE}"
wget "${HG38_FTP_URL}${HG38_GENES_EXPRESSION_TABLE_FILE}"  --directory-prefix="${HUMAN_GENES_EXPRESSION_DIR}"
echo "Processing Hg38 Genes Expression Table ${HG38_GENES_EXPRESSION_TABLE_FILE}"
zcat "${HUMAN_GENES_EXPRESSION_DIR}/${HG38_GENES_EXPRESSION_TABLE_FILE}" | awk '{OFS ="\t"} {print $1,$2,$3,$4,$10,$6}'| gzip > "${HUMAN_GENES_EXPRESSION_DIR}/${HG38_GENES_EXPRESSION_FILE}"
rm "${HUMAN_GENES_EXPRESSION_DIR}/${HG38_GENES_EXPRESSION_TABLE_FILE}"
echo "Done Processing Hg38 Genes Expression Table ${HG38_GENES_EXPRESSION_TABLE_FILE}"

fi

#---------------------------------------------------------------------------
# Create INI File
#---------------------------------------------------------------------------
if [ "${DONT_WRITE}" = false ]
then

DBS_PATHS_INI=${3:-"${RESOURCES_DIR}/ResourcesPaths.ini"};
echo "[DEFAULT]" > ${DBS_PATHS_INI}
echo "ResourcesDir = ${RESOURCES_DIR}" >> ${DBS_PATHS_INI}
echo "BEDToolsPath = ${BEDTOOLS_PATH}" >> ${DBS_PATHS_INI}
echo "SAMToolsPath = ${SAMTOOLS_PATH}" >> ${DBS_PATHS_INI}
echo "JavaHome = ${JAVA_HOME}" >> ${DBS_PATHS_INI}
echo "BAMUtilsPath = ${BAM_UTILS_PATH}" >> ${DBS_PATHS_INI}
echo "EIJavaUtils = ${LIB_DIR}/EditingIndexJavaUtils.jar" >> ${DBS_PATHS_INI}

echo "[hg38]" >> ${DBS_PATHS_INI}
echo "Genome =  ${HUMAN_GENOME_DIR}/${HG38_GENOME_FASTA}" >> ${DBS_PATHS_INI}
echo "RERegions = ${HUMAN_REGIONS_DIR}/${HG38_REGIONS_FILE}" >> ${DBS_PATHS_INI}
echo "SNPs = ${HUMAN_SNPS_DIR}/${HG38_SNPS_FILE}" >> ${DBS_PATHS_INI}
echo "RefSeq = ${HUMAN_REFSEQ_DIR}/${HG38_REFSEQ_FILE}" >> ${DBS_PATHS_INI}
echo "GenesExpression = ${HUMAN_GENES_EXPRESSION_DIR}/${HG38_GENES_EXPRESSION_FILE}" >> ${DBS_PATHS_INI}
echo "" >> ${DBS_PATHS_INI}

fi
