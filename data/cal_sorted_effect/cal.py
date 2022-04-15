import csv

def read_csv(filepath, encoding='utf-8-sig'):

    data = []
    with open(filepath, 'r', encoding=encoding) as file_obj:
        reader = csv.reader(file_obj, delimiter=',')
        for line in reader:
            data.append(line)
        return data

def cal_perf_gain(data, engine_size):
    
    count = 0
    perf_gain = 0
    for da in data:
        if int(da[0]) == engine_size:
            perf_gain += float(da[2])
            count += 1

    return perf_gain/count

def main():
    data = read_csv("output.csv")
    avg = cal_perf_gain(data[1:], 1)
    print("Engine_size 1, avg. perf. gain = ", avg, " %")
    avg = cal_perf_gain(data[1:], 2)
    print("Engine_size 2, avg. perf. gain = ", avg, " %")
    avg = cal_perf_gain(data[1:], 4)
    print("Engine_size 4, avg. perf. gain = ", avg, " %")
    avg = cal_perf_gain(data[1:], 8)
    print("Engine_size 8, avg. perf. gain = ", avg, " %")
    avg = cal_perf_gain(data[1:], 16)
    print("Engine_size 16, avg. perf. gain = ", avg, " %")
    
if __name__ == "__main__":
    main()