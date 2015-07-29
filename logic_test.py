def main():
    
    a = [1,1,2,2,2,3,3,3,3]
    size=0
    groups=0

    i=0
    
    while i<len(a):
        num=a[i]
        j=i+1
        a1=[a[i]]
        while j<len(a) and a[j] == num:
            a1.append(a[j])
            j+=1
        print(a1)
        i+=j
        groups+=1
        
    print(groups)

main()
