# **Memory Leaks in iOS: Find, Diagnose, & Fix (2022)**



https://infinitt.tistory.com/403 에 포스팅 되어있음.



# 메모리 누수란 ?

retain cycle로 인해 메모리에서 객체를 할당 해제할 수 없는 경우에 발생한다. Swift는 ARC를 통해 메모리 관리를 하는데, 두 객체 이상이 서로에 대해 강한 참조를 하는 경우에 retain cycle이 발생한다. 결과적으로 참조 카운팅이 0이 되지 않아 deinit이 호출되지 않는다.

(자세한 내용은 ARC에 대해 알아보면 된다.)

```
class A{
    var b: B?
}
class B{
    var a: A?
}
func makeMemoryLeaks(){
    let a = A()
    let b = B()
    a.b = b
    b.a = a
}
```

간단히 예를 들면 , a는 클래스 B의 인스턴스인 b를 참조한다. 그리고 클래스 B의 인스턴스 b 는 클래스 A의 인스턴스 a 를 참조하고있다. 따라서 a, b는 결국 끝까지 레퍼런스 카운트를 1로 유지하며 할당 해제되지 못한채 메모리 누수를 발생시킨다.





## 그렇다면 메모리 누수를 어떻게 발견할 수 있을까?

여러가지 방법이 있겠지만, 두 가지 방법을 찾아보았다.

1. Xcode - Memory graph debugger
2. Instrument - Leaks

#  

# 1. Xcode - Memory graph debugger

### 설정



![img](https://blog.kakaocdn.net/dn/bc3AjX/btrvLIgGbbb/khsXbeLDF2YMPkaouXcnQ0/img.png)

![img](https://blog.kakaocdn.net/dn/ofagc/btrvLhKoAAq/ANKsfC72Bk1xcHrmjQkUy1/img.png)



실행하기 전에 Edit Scheme로 들어가서 Diagnostics 설정을 위 사진처럼 바꾸어준다.

- Live Allocation Only : All Allocations 보다 오버헤드가 적다. 리테인 사이클이나 메모리 누수를 식별할때 필요한 항목.

###  

###  

### 실행



![img](https://blog.kakaocdn.net/dn/kFLzP/btrvKKTBTqj/t2VPkkJflvA689H4I7FRok/img.png)



Xcode 콘솔창 윗부분에 아래 버튼을 클릭하면 실행할 수 있다.

버튼을 누르게 되면 앱 실행을 중지하고 현재 상태의 힙에 대해 스냅샷을 찍는다. 그리고 남아있는 객체들과 메모리에 유지되고 있는 참조 체인이 표시된다.



![img](https://blog.kakaocdn.net/dn/BWkpf/btrvIzr2tQx/k3tx4o9EcPm0rh3NAhKlGk/img.png)



좌측에 힙에 있는 객체 리스트들이 나타난다. 인스턴스 이름, 인스터스의 개수, 그리고 인스턴스의 주소값 등이 표시된다.

그리고 보라색 경고표시는 메모리 누수에 대한 경고이다. 아까 클래스 A, B를 서로 상호참조 하게하였더니 Xcode가 감지하고 알려주는 모습이다.



**중요한 점은 메모리 누수는 Xcode가 자동으로 찾아주는 경우 보다 개발자가 직접 찾아야 하는 경우가 더 많다. 실제로 몇개의 Retain cycle을 만들어 테스트 해 보았는데, 자동 감지가 안되는 경우가 더 많았다. 해당 코드는 게시글 하단에 git레포에 있다.**

```
A (3)
	0x60000210c5a0
	0x6000010c05a0
	0x6000020c13a0

객체 (인스턴스의 개수)
	인스턴스의 주소
```

##  

##  

## Object references



![img](https://blog.kakaocdn.net/dn/dse97G/btrvLf6XpmO/u8ugZYzF7hQjIym1JknfLk/img.png)



객체를 클릭하면 위와 같은 객체 그래프들이 그림으로 나타난다.

굵은선 → 강한 참조를 의미한다.

연한선 → 알 수 없는 참조를 의미한다. (강한 참조일 수도 있고, 약한 참조일 수 도 있다.)

간단하게 메모리 그래프 디버거의 기능에 대해 알아봤다.

### 그렇다면 누수를 확인하려면 어떻게 할까?

테스트할 기능에 대해 실행하고, 이를 여러번 반복한다. 그리고 앱의 스냅샷을 확인한다.

1. 반복적으로 기능을 테스트했을때 메모리 사용량이 늘어났다면 누수를 의심할 수 있다.
2. 인스턴스 개수가 많아도 메모리 누수 징후일 수 있다.
3. 왼쪽 패널 리스트에 현재 앱 상태에서 있으면 안되는 객체/클래스/뷰 등이 표시되고 있는지 확인한다.

 

# Instrument - Leaks

Instrument는 스냅샷을 찍는게 아니라 다이나믹하게 메모리를 프로파일링 할 수 있다. (실행해도 앱이 일시정지 되지 않으며, 앱에서 기능을 실행시키면 동적으로 인스턴스들과 메모리를 추적한다)

instrument에서 Leaks를 실행시킨다.



![img](https://blog.kakaocdn.net/dn/XKBfU/btrvJSR9bRo/Eswc70q5EvKXcZOD9c2ug1/img.png)



그리고 상단에 디버깅할 Target(앱)을 선택할 수 있다.



![img](https://blog.kakaocdn.net/dn/bbC9Pp/btrvKJNUPsG/wHMvlTgoiVSiHHVnQjgnc0/img.png)



그리고 빨간색 녹화버튼? 을 닮은 버튼을 클릭하면 Leaks이 동작한다.



![img](https://blog.kakaocdn.net/dn/bw0Uaz/btrvGZkrxPC/C3mOBKmav45XkD5CLsYVuk/img.png)



감지된 인스턴스에 대한 목록과 ARC의 레퍼런스 카운트까지 표시된다.



![img](https://blog.kakaocdn.net/dn/br1Nge/btrvJ8AryfY/bNxKtJ6kNmKeJMyAPkKVh0/img.png)



하단 필터에서 현재 실행중인 앱 이름을 검색하면 관련있는 인스턴스들에 대해서만 편하게 볼 수 있다.

###  

### **Memory Leak Test**

**https://github.com/Youjunyong/MemoryLeaks.git**

###  

###  

### **참고자료**

https://www.youtube.com/watch?v=b2AgibUg47k

https://doordash.engineering/2019/05/22/ios-memory-leaks-and-retain-cycle-detection-using-xcodes-memory-graph-debugger/

 