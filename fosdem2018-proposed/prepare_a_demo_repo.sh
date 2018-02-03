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
for i in $(seq 1 41); do echo -e "// comment $i\n" >> bisect.go; git commit -a -m "Commit $i" ; done
sed -i 's/true/false/' bisect.go
git add bisect.go
git commit -m "Commit 42"
for i in $(seq 43 100); do echo -e "func Foo$i() int {return $i}\n" >> bisect.go; git commit -a -m "Commit $i" ; done


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

