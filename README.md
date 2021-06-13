# English SMS Collection
We used this collection to analyse the relationship between features size and classification performance.

If you use this collection, please cite our paper:

Content-based SMS Classification: Statistical Analysis for the Relationship between Features Size and Classification Performance (http://www.cys.cic.ipn.mx/ojs/index.php/CyS/article/view/2593)

This collection was constructed using SMS spam collection, DIT SMS spam, and British English SMS datasets.

The content of EnglishSMSCollection.mat (https://github.com/Waddah-Saeed/EnglishSMSCollection/blob/master/EnglishSMSCollection.mat) is:

ClassInfo: This variable just to inform the researchers that we represent Legitimate and Spam classes in Folds and FullSMStext variables by 1 and 2, respectively.

FullSMStext: The final English SMS collection from which we created the folds.

Folds: The 10-folds used in the paper. The first column in each row represents the training samples for that fold, while the second column is the test samples.
