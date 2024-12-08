# Biomedical Informatics Project
Group members: Leah Masschelein, Helena Martínez, Clara Wagner, Gabriel Pino

## Introduction
Developing effective tools for understanding and managing complex diseases requires innovative approaches to leverage the wealth of data available in modern healthcare. This project focuses on creating an advanced predictive model to identify risk factors, clinical patterns, and biomarkers linked to breast cancer. By integrating diverse data -encompassing genetics and general health information-, this model aims to estimate the risk of obtaining breast cancer. Our model is complemented by an interactive API for seamless integration into clinical workflows and a Shiny application to facilitate user-friendly exploration.

## Phase One
### Literature review
Breast cancer is a complex disease influenced by a variety of risk factors. The primary contributors include gender, age, family history (genetics), and reproductive or hormonal factors [1-3]. Additional considerations such as geography, race, ethnicity, and lifestyle choices may also play a role:
* Gender: Less than 1% of the cases of breast cancer are men [1]. 
* Age: The risk of developing breast cancer increases with age, doubling approximately every decade before menopause. However, the increase slows significantly after menopause. [2]
* Family history: Mutations in certain genes significantly elevate breast cancer risk. The genetics linked to breast cancer are very complex, but BRCA1 and BRCA2 are among the most important genes. Mutations in these genes are present in around 5 % of all breast cancers [4-5], and carry a lifetime risk of 50-85% [6]. 
* Reproductive and hormonal factors:
    * Age of menopause: A late onset of menopause increases the risk of breast cancer [1-3]
    * Hormone therapy (HR): The use of hormone therapy has been linked to an increased risk of breast cancer in some studies [2-3]

Geography and ethnicity also play a role in breast cancer risk. For instance, breast cancer incidence is higher in developed countries [1-2]. However, data collection challenges and inconsistent findings across populations led to their exclusion from this model. Other potential risk factors, such as smoking or alcohol consumption, remain inconclusive and were excluded for similar reasons [1-3]. 

### Data collection
The dataset used to train the model is derived from the METABRIC dataset (Nature, 2012 & Nature Communications 2016) [7]. This extensive dataset includes genomic, transcriptomic, and clinical information from 2509 breast cancer patients. All patients are female and represented by one sample. An important note is that the dataset predominantly comprises patients from the United Kingdom and Canada. 

The dataset provides a large number of features, therefore only the relevant features are discussed. Downloading the dataset provides a zipped file with multiple datasets. In this project, ‘data_clinical_patient.txt’ and ‘data_clinical_sample.txt’ are used. We selected the following data for the project:
* Patient ID: A unique identifier for each patient
* Age at diagnosis: Numeric value representing the age when breast cancer was diagnosed.
* Inferred menopausal state: Categorical value (pre or post). Patients over 50 were classified as postmenopausal, while those under 50 were premenopausal. Missing values were imputed with the mode.
*	Hormone therapy: Categorical value (yes or no). Missing values were imputed with the mode.
*	Oncotree code: A classification system for tumor subtypes, which was used to determine whether a patient carried a BRCA mutation. Patients with "BRCA" in their Oncotree code were assigned a BRCA value of 1; others received 0.

To create a control group, a synthetic dataset was generated in R with similar features. The control dataset was designed to reflect the distribution of the general UK female population in 2012. Key characteristics included:
* Patient ID: Unique identifier for each patient 
*	Age: Randomly sampled from a distribution resembling the UK female population aged 20–100 [8].
*	Inferred menopausal state: Categorical (pre or post). Set to post for individuals over 50 and pre otherwise.
*	Hormone therapy: Randomly assigned yes or no.
*	BRCA gene:  Assigned based on prevalence. Approximately 0.3% of the healthy population carried a BRCA mutation [9].

The processed METABRIC dataset and the synthetic control data were merged into a single unified dataset for training the model. The Database+TrainingModel.R file contains the complete code used to prepare the datasets and train the model. Details of the model training process are discussed in the subsequent section.

### Model training
The logistic regression model was designed to predict the likelihood of developing breast cancer using:
* BRCA mutation status
* Age
* Inferred menopausal state
* Hormone therapy use

The model was evaluated based on:
1. Accuracy: The proportion of correct predictions.
2. Sensitivity: The ability to correctly identify individuals with cancer.
3. Specificity: The ability to correctly identify healthy individuals.
To optimize the model's performance, the decision threshold for classifying an individual as "at risk" was adjusted to 0.7, prioritizing sensitivity to minimize missed diagnoses.

### API development
The API was implemented using the Plumber package in R. It allows external systems to interact with the predictive model via RESTful endpoints. Users can send patient data (e.g., age, BRCA status) and receive cancer risk predictions. This facilitates integration into electronic health record (EHR) systems or decision-support tools.
The code to develop the API can be found in api.R

## Phase Two 
### Front-End Development
A Shiny application provides an interactive interface for users to test the model. Users can input patient data (age, menopausal status, etc.) and view real-time predictions. While the API enables integration into broader systems, Shiny serves as a standalone visualization tool for researchers and clinicians.


### References
[1] McPherson, K., Steel, C. M., & Dixon, J. M. (2000). Breast cancer—epidemiology, risk factors, and genetics. BMJ, 321(7261), 624–628. Retrieved from https://research-repository.st-andrews.ac.uk/bitstream/handle/10023/4669/mcpherson2000bmj624.pdf?sequence=1

[2] Breast Cancer Risk in Women. (n.d.). Retrieved from https://www.tandfonline.com/doi/full/10.2147/BCTT.S176070#d1e162

[3] Collaborative Group on Hormonal Factors in Breast Cancer. (2012). Menarche, menopause, and breast cancer risk: Individual participant meta-analysis, including 118,964 women with breast cancer and 306,691 women without breast cancer from 117 epidemiological studies. The Lancet Oncology, 13(11), 1141–1151. Retrieved from https://pmc.ncbi.nlm.nih.gov/articles/PMC5715522/

[4] Couch, F. J., et al. (1996). BRCA1 mutations in women attending clinics that evaluate the risk of breast cancer. Mayo Clinic Proceedings, 71(9), 897–904. Retrieved from https://www.sciencedirect.com/science/article/abs/pii/S0025619611647307

[5] Kuchenbaecker, K. B., et al. (2017). Risks of breast, ovarian, and contralateral breast cancer for BRCA1 and BRCA2 mutation carriers. JAMA Oncology, 3(1), 19–27. Retrieved from https://jamanetwork.com/journals/jamaoncology/fullarticle/2618073

[6] King, M. C., Marks, J. H., & Mandell, J. B. (2001). Breast and ovarian cancer risks due to inherited mutations in BRCA1 and BRCA2. New England Journal of Medicine, 344(5), 279–287. Retrieved from https://www.nejm.org/doi/full/10.1056/NEJM200102223440801

[7] METABRIC Study: Molecular Taxonomy of Breast Cancer International Consortium. (n.d.). Retrieved from https://www.cbioportal.org/study/summary?id=brca_metabric

[8] Office for National Statistics. (2013). National Population Projections, 2012-based Statistical Bulletin. Retrieved from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/bulletins/nationalpopulationprojections/2013-11-06
