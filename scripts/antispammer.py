import antispam
import csv
import os

csvTrain = os.path.abspath(os.path.join(os.path.dirname(__file__), 'trianEdge_dummy.csv'))
modelFile = os.path.abspath(os.path.join(os.path.dirname(__file__), 'my_model.dat'))
spam = True;
def test():
    d = antispam.Detector(modelFile)
    with open(csvTrain) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            print("test-x", row['x'], row['length'])
            if row['ham'] == 1:
            	spam = False;
            d.train(row["Text"], spam)
test()