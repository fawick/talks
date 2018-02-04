# create the initial commit
rm -rf .git
git init
cat > bisect.go <<EOF
package bisect

func canDo() bool {
    return true
}
EOF

git add bisect.go
git commit -m "Initial commit"
git tag initialCommit


# create a bunch of commits rand randomy hide the bug in one of them
MAX=1000
rand=$(echo "$RANDOM%$MAX"|bc)

for i in $(seq 1 $(($rand-1))); do 
    echo -e "// comment $i\n" >> bisect.go
    git commit -a -m "Commit $i" 
done
sed -i 's/true/false/' bisect.go
git add bisect.go
git commit -m "Commit $rand" -m "Spoiler alert, this is the bad commit"
for i in $(seq $(($rand+1)) $MAX); do 
    echo $i
    echo -e "func Foo$i() int {return $i}\n" >> bisect.go
    git commit -a -m "Commit $i" 
done


# automate the search for the commit that changed canDo from true to false
cat > bisect_test.go <<EOF
package bisect

import "testing"

func TestCanDo(t *testing.T) {
	if !canDo() {
		t.Fail()
	}
}
EOF

git bisect start
git bisect bad master
git bisect good initialCommit
git bisect run go test -run CanDo

