# Biomedical Informatics Project
Group members: Leah Masschelein, 

## Introduction
Developing effective tools for understanding and managing complex diseases requires innovative approaches to leverage the wealth of data available in modern healthcare. This project focuses on creating an advanced predictive model to identify risk factors, clinical patterns, and biomarkers linked to breast cancer. By integrating diverse data, genetics and general health information, this model aims to estimate the risk of obtaining breast cancer. An interactive API is developed to allow easy interaction with the model. 

## Phase One
### Literature review
Breast cancer is a complex disease influenced by a variety of risk factors. The primary contributors include gender, age, family history (genetics), and reproductive or hormonal factors [1-3]. Additional considerations such as geography, race, ethnicity, and lifestyle choices may also play a role.
* Gender: Less than 1% of the cases of breast cancer are men [1]. 
* Age: The risk of developing breast cancer increases with age. Before menopause, the risk approximately doubles every decade. However, this rate of increase slows significantly after menopause. [2]
* Family history: Mutations in certain genes significantly elevate breast cancer risk. The genetics linked to breast cancer are very complex, but BRCA1 and BRCA2 are among the most important genes. Mutations in these genes are present in around 5 % of all breast cancers [4-5], and carry a lifetime risk of 50-85% [6]. 
* Reproductive and hormonal factors:
    * Age of menopause: A late onset of menopause increases the risk of breast cancer [1-3]
    * Hormone therapy (HR): Hormone therapy use has been linked to an increased risk of breast cancer in some studies [2-3]

The risk of breast cancer is also influenced by geography, race and ethnicity. The incidence of breast cancer is higher in developed countries [1-2]. However, due to challenges in gathering comprehensive data from diverse populations, these factors were excluded as variables in this project. Other risk factors can be linked to lifestyle choices, such as smoking and alcohol, although findings are inconsistent and vary between studies [1-3]. 

### Data collection
The dataset used to train the model is based on the Breast Cancer (METABRIC, Nature 2012 & Nat Commun 2016) dataset [7]. This dataset was originally published in Nature (2012) and expanded in Nature Communications (2016). It provides extensive genomic, transcriptomic, and clinical data from 2509 breast cancer patients. All patients are female and represented by one sample. An important note is that the dataset predominantly comprises patients from the United Kingdom and Canada. 

The dataset provides a large number of features, therefore only the relevant features are discussed. Downloading the dataset provides a zipped file with multiple datasets. In this project, ‘data_clinical_patient.txt’ and ‘data_clinical_sample.txt’ are used. These provide following data for the project:
* Patient ID: unique identifier for each patient
* Age at diagnosis: age at which the cancer was detected (numeric value)
* Inferred menopausal state: indicates whether the patient is pre- or post-menopause (categorical value: pre, post and NA)
    *	Note: patients are classified as post for patients over 50 and pre for patients under 50
*	Hormone therapy: indicates whether or not the patient receives hormone therapy (categorical value: yes, no and NA)
*	Oncotree code: classification system for tumor subtypes, providing detailed information on tumor characteristics, including whether the patient has a mutation in one of the BRCA genes (categotical value: BRCA, IDC, MDLC, etc.)

With these selected features, a new cancer dataset was created, which contained following features:
* Patient ID: unique identifier for each patient 
*	Age: numerical value, equal to age at diagnosis 
*	Inferred menopausal state: categorical value (pre or post) 
    *	The NA values were replaced with … ?
*	Hormone therapy: categorical value (yes or no)
    * The NA values were replaced with … ?
* BRCA gene: categorical value (0 or 1)
    * The OncoTree Code was used to assign a value of 1 if the patient had a BRCA mutation, and 0 otherwise.

To create a control group, a synthetic dataset was generated in R with similar features. The control dataset was designed to reflect the distribution of the general UK female population in 2012. Key characteristics included:
* Patient ID: unique identifier for each patient 
*	Age: numerical value, randomly sampled with a distribution resembling the UK female population between 20 and 100 [8].
*	Inferred menopausal state: categorical value (pre or post). Set to pre for patients under 50 and post for those over 50.
*	Hormone therapy: categorical value (yes or no). Randomly assigned yes or no.
*	BRCA gene: categorical value (0 or 1). Randomly assigned based on population prevalence.
Approximately 0.3% of the healthy control population was assigned a BRCA mutation (source?).

The cancer dataset and the healthy control dataset were merged into a single unified dataset for training the model. The Database+TrainingModel.R file contains the complete code used to prepare the datasets and train the model. Details of the model training process are discussed in the subsequent section.

### Model training
Explanation what the model does: 

### API development
The code to develop the API can be found in api.R

### References
[1] https://www.tandfonline.com/doi/full/10.2147/BCTT.S176070#d1e162

[2] https://research-repository.st-andrews.ac.uk/bitstream/handle/10023/4669/mcpherson2000bmj624.pdf?sequence=1 

[3] https://pmc.ncbi.nlm.nih.gov/articles/PMC5715522/ 

[4] https://www.sciencedirect.com/science/article/abs/pii/S0025619611647307

[5] https://jamanetwork.com/journals/jamaoncology/fullarticle/2618073 

[6] https://www.nejm.org/doi/full/10.1056/NEJM200102223440801 

[7] https://www.cbioportal.org/study/summary?id=brca_metabric 

[8] https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/bulletins/nationalpopulationprojections/2013-11-06


