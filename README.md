# English SMS Collection
We used this collection to analyse the relationship between features size and classification performance. This collection was constructed using SMS spam collection, DIT SMS spam, and British English SMS datasets.

If you use this collection, please cite our paper:

Content-based SMS Classification: Statistical Analysis for the Relationship between Features Size and Classification Performance (http://www.cys.cic.ipn.mx/ojs/index.php/CyS/article/view/2593)

-----------

The content of EnglishSMSCollection.mat (https://github.com/Waddah-Saeed/EnglishSMSCollection/blob/master/EnglishSMSCollection.mat)

- *ClassInfo*: This variable just to let you know that we represent Legitimate and Spam classes in *Folds* and *FullSMStext* variables by 1 and 2, respectively.

- *FullSMStext*: Our English SMS collection from which we created the folds.

- *Folds*: The 10-folds used in the paper. The first column in each row represents the training samples for that fold, and the second column is the test samples.

----------

The content of IG.zip (https://github.com/Waddah-Saeed/EnglishSMSCollection/blob/master/IG.zip)

In this file, each SMS text message was represented using the vector space model. The vector’s dimensions in this model represent the top 50% features selected using the information gain method, and each entry of the vector represents the feature’s weight. Each feature was weighted using the normalized logarithm of term frequency-inverse document frequency weighting function.
