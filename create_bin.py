
x = [];

def plot(xx,yy,arr=None):
    if(arr == None):
        y = []

        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
        
        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
        y.append([0,0,0,0,0,0,0,0])
    else:
        y = arr
    y[yy][xx] = 1

    return y


    


print hex(int('00000000',2))




def print_plot(p):
    for i in p:
        print i


def print_hex(p, var="", end=""):
    count = 0
    for i in p:

        bin = ""
        for k in i:
            bin +=str(k)
#        print bin
        print var+"["+str(count)+"] =",hex(int(bin,2)),end
#        print hex(int(i,2))
        count +=1


def invert(arr):
    ycount = 0

    for i in arr:
        
        xcount = 0
        for k in i:
            if k == 1:
                arr[ycount][xcount] = 0
            else:
                arr[ycount][xcount] = 1
            xcount +=1
        ycount +=1
    return arr

arr = plot(0,0)
p = []
for z in range(7):
    print "-----"
    p = plot(z,z,arr)

print_hex(p, "dataY", ";")
p = invert(p)
print "//---"
print_hex(p, "dataX", ";")
