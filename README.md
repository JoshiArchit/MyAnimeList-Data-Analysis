<h1>CSCI620 - Introduction to Big Data<br>
Project Repository, Spring 2023<br></h1>
<h3>Authors/Collaborators - <br></h3>
  <ul>
    <li>Athina Stewart</li>
    <li>Archit Joshi</li>
    <li>Chengzi Cao</li>
    <li>Parijat Kawale</li>
  </ul>

<h3>Overview</h3>
This repository is a collection of JS, Python and SQL scripts to load and perform analysis on the MyAnimeList dataset from Kaggle for the CSCI620 Course project. Data loading, analysis and comparisons performed between PostgreSQL and MongoDB<br>
Dataset - https://www.kaggle.com/datasets/azathoth42/myanimelist

- Project split into 3 phases.
- Please refer to each Phase report for information.
- Each subsequent phase assumes previous phase has been executed and the data is present in the postgreSQL and MongoDB
- Refer to <b>CSCI620 - Project Presentation</b> for an overview of the project lifecycle.

<h3>Phase 1</h3>
<ul>
  <li>This phase deals with selecting a viable dataset to load and perform analysis on using a relational model.</li>
  <li>Please refer to <b>CSCI620 - Report Phase 1.pdf</b> for more information and script execution instructions.</li>
  <li>
    The Objectives of this phase include -
    <ol>
      <li>Select one or more datasets. The final dataset needs to be large (~50M tuples in a
        relational database), and interesting enough so you can perform meaningful queries and mine
        meaningful information from it.</li>
      <li>Provide a description of the data and a meaningful relational model to faithfully represent the dataset.</li>
      <li>Provide a program to load the dataset.</li>
    </ol>
  </li>
</ul>

<h3>Phase 2</h3>
<ul>
  <li>This phase deals with proposing and loading the data set using a document-oriented model</li>
  <li>Please refer to <b>CSCI620 - Report Phase 2.pdf</b> for more information and script execution instructions.</li>
  <li>
    The Objectives of this phase include -
    <ol>
      <li>Propose a document-oriented model for the dataset and compare it with the relational model</li>
      <li>Provide code to load your data into this model.</li>
      <li>Provide a program that issues at least five interesting SQL queries over the previous relational model and propose indexes to speed up query 
      execution (report your timings).</li>
      <li>Discover and explain functional dependencies and discuss normalization with respect to the relational model you provided in Phase I. </li>
    </ol>
  </li>
</ul>

<h3>Phase 3</h3>
<ul>
  <li>This phase deals with data cleaning, integration and item set mining.</li>
  <li>Please refer to <b>CSCI620 - Report Phase 3.pdf</b> for more information and script execution instructions.
  <li>
    The Objectives of this phase include -
    <ol>
      <li>Provide a program that cleans and integrates your dataset.</li>
      <li>Generate and discuss a few statistical observations from the dataset.</li>
      <li>Provide a program tha applies itemset mining to the dataset to discover association rules. We have opted to use the apriori algorithm to achieve the same.</li>
      <li>A comparison study on the better model fit for the dataset and the tasks performed on it.</li>
    </ol>
  </li>
</ul>
