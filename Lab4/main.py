import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split 
from sklearn.tree import DecisionTreeClassifier 
from sklearn.metrics import accuracy_score
from sklearn.tree import export_graphviz
from sklearn.externals.six import StringIO
from sklearn.metrics import classification_report 
from sklearn.metrics import f1_score
from sklearn import preprocessing
import pydot
import csv

features = [
    "MVP", 
    "Gold_Glove", 
    "Cy_Young_Award", 
    "All_Star_Game", 
    "Batting_Seasons_Number", 
    "Batting_LastSeason",
    'Batting_Games',
    'Batting_At_Bats',
    'Batting_Runs',
    'Batting_Hits',
    'Batting_Doubles',
    'Batting_Triples',
    'Batting_Homeruns',
    'Batting_Runs_Batted_In',
    'Batting_Stolen_Bases',
    'Batting_Caught_Steading',
    'Batting_Base_on_Balls',
    'Batting_Intentional_walks',
    'Batting_Hit_by_pitch',
    'Batting_Sacrifice_hits', 
    'Batting_Grounded_into_double_plays',
    'Pitching_Wins',
    'Pitching_Games',
    'Pitching_Shutouts',
    'Pitching_Saves',
    'Pitching_Outs_Pitched',
    'Pitching_Earned_Runs', 
    'Pitching_Strikeouts',
    'Pitching_ERA',
    'Pitching_HBP',
    'Pitching_BK',
    'Pitching_BFP',
    'Pitching_GF',
    'Pitching_R'
]

classification = ['inducted']

def import_data():
    # Import csv file and first column as header
    data = pd.read_csv('data.csv', header = 0)

    return data

def divid_data(data):
    # Replace NULL to 0 in the dataset
    data = data.fillna(0)

    # label encoding
    le = preprocessing.LabelEncoder()
    data = data.apply(le.fit_transform)

    # Dividing the dataset into training set (80%) and the testing set (20%)
    train, test = train_test_split(data, test_size = 0.2)

    # Separate features and target
    X_train = train[features]
    Y_train = train[classification]

    X_test = test[features]
    Y_test = test[classification]

    return X_train, X_test, Y_train, Y_test

def hall_of_fame_classifier(data, impurity_measure, iteration_count):
    result = []
    X_train, X_test, Y_train, Y_test = divid_data(data)

    # Initalize the mode
    decision_tree_model = DecisionTreeClassifier(criterion = impurity_measure)
    # Train the model
    decision_tree_model.fit(X_train, Y_train) 

    # feature_selection = pd.Series(decision_tree_model.feature_importances_)
    # feature_selection = feature_selection.sort_values()
    # for feature_index, importance in feature_selection.iteritems():
    #     print((features[feature_index], importance))

    plot_decision_tree(decision_tree_model, "{}.png".format(impurity_measure))

    # Predict
    Y_train_predit = decision_tree_model.predict(X_train)
    # Calulate accurancy
    train_accuracy = accuracy_score(Y_train, Y_train_predit) 

    print("Train Accuracy: ", train_accuracy)
    print("Confusion Matrix: ", confusion_matrix(Y_train, Y_train_predit)) 
    print("Report: ", classification_report(Y_train, Y_train_predit))
    print('f1 score: ', f1_score(Y_train, Y_train_predit))

    # Predict
    Y_predit = decision_tree_model.predict(X_test)
    # Calulate accurancy
    test_accuracy = accuracy_score(Y_test, Y_predit) 

    print("Test Accuracy: ", test_accuracy)
    print("Confusion Matrix: ", confusion_matrix(Y_test, Y_predit)) 
    print("Report: ", classification_report(Y_test, Y_predit))

    for i in range(iteration_count):
        print("{} test # {}".format(impurity_measure, i))

        # get next 20% test dataset
        _, X_test, _, Y_test = divid_data(data)

        # Predict
        Y_predit = decision_tree_model.predict(X_test)
        # Calulate accurancy
        test_accuracy = accuracy_score(Y_test, Y_predit) 

        print("Test Accuracy: ", test_accuracy)
        print("Confusion Matrix: ", confusion_matrix(Y_test, Y_predit)) 
        print("Report: ", classification_report(Y_test, Y_predit))

        result.append((test_accuracy, Y_test, Y_predit))

    return result

def plot_decision_tree(decision_tree, file_name):
    dot_data = StringIO()
    export_graphviz(
        decision_tree, 
        out_file = dot_data, 
        feature_names = features, 
        class_names = ['nominated', 'elected'], # Alphapetical order
        filled = True,
        rounded = True,
        special_characters = True
    )
    graph = pydot.graph_from_dot_data(dot_data.getvalue())
    graph[0].write_png(file_name)

def output_csv(results, impurity_measure):
    # Write Accuracy
    writer = csv.writer(open('g_6_DT_{}_accuracy.csv'.format(impurity_measure),'w+'))
    writer.writerow(("Dataset number", "Accuracy", ""))
    for i in range(len(results)):
        accuracy, _, _ = results[i]
        writer.writerow((i + 1, accuracy, ""))

    # Write Predication result
    writer = csv.writer(open('g_6_DT_{}_predictions.csv'.format(impurity_measure),'w+'))
    writer.writerow(("Iteration", "Classification", "Prediction"))
    for i in range(len(results)):
        _, Classification, Prediction = results[i]
        for j in range(len(Classification)):
            writer.writerow((
                i + 1, 
                Classification.iloc[j]["inducted"], 
                Prediction[j]
            ))


def main():
    data = import_data()

    writer = csv.writer(open('g_6_DT_gini.csv','w+'))
    results = hall_of_fame_classifier(data, "gini", 5)
    output_csv(results, "gini")

    writer = csv.writer(open('g_6_DT_entropy.csv','w+'))
    results = hall_of_fame_classifier(data, "entropy", 5)
    output_csv(results, "entropy")

if __name__ == "__main__":
    main()