
sequence <- "CAGCAGGGGGACCACATACGGGTACACCTGCCCGCCGGCAAGATGCGCCAGATGAGGATACAAATCCGCC"

AGGGACATCAGGGATACCGCATTGAAGAGCGCCATCAGCGGGTCAATTTTTCCCCGTCCACTGGCCTGTTTGGTGATAAGAATGGCGTTACCTTTAGGCTCCACCCGGGCATTGCCGACACACCAGGCCATCAGGGGCTGGTCACCATGCACCAGCACCCCTTCAGCCAGTTTGCGCTCGGTGGTTTTAATGGCCCCGCCCAGTTTCCAG
Is this input a nucleotide sequence? Answer TRUE or FALSE only.



#Nucleotide sequence homology (NSH) search
NSH_search <- function(sequence, api_key){

#Progress bar
pb <- progress::progress_bar$new(total = 3)

s1 <- paste0(sequence, ": Is this input a nucleotide sequence? Answer TRUE or FALSE only.")
response1 <- chatAI4R::chat4R(s, api_key)$choices.message.content

pb$tick()
if(!as.logical(response1)){
  message("Input data is not nucleotide sequence"); stop()
}

s2 <- paste0(sequence, ": What kind of sequence is this sequence? Answer species only. if unknown, answer 'Unknown' only")
response2 <- chatAI4R::chat4R(s2, api_key)$choices.message.content

pb$tick()
if(!as.logical(response1)){
  message("This sequence is unknown."); stop()
}else{
  message(response2); stop()
}

}


