#!/bin/sh

if [ -L $0 ]; then
    cd $(dirname $(readlink $0))
else
    cd $(dirname $0)
fi

readonly DOCUMENTATION_ROOT=$(pwd); export DOCUMENTATION_ROOT

start_body () {

    echo '<html>'
    echo '<head>'
    echo '<meta charset="utf-8">'
    echo '<style>'
    cat $DOCUMENTATION_ROOT/parts/main.css
    echo '</style>'
    echo '</head>'
    echo '<body>'


}

end_body () {

echo '</body>'
echo '</html>'

}

generate_toc () {

    echo '<nav>'
    echo '<h2>Table of contents</h2>'
    echo '<ol>'
    for CONTENT in $(ls $DOCUMENTATION_ROOT/parts/contents); do
        echo '<li>'
        echo "<a href=\"contents/$(echo $CONTENT | cut -d_ -f2-)\">"
        echo $CONTENT | cut -d_ -f2- | cut -d. -f1
        echo '</a>'
        echo '</li>'
    done
    echo '</ol>'
    echo '</nav>'

}

### Write document as separate HTML file by content

## Summary and table of contents
WRITE_TO=$DOCUMENTATION_ROOT/index.html
:> $WRITE_TO
start_body >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/header.html >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/summary.html >> $WRITE_TO
generate_toc  >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/footer.html  >> $WRITE_TO
end_body >> $WRITE_TO

## Separate contents
rm -rf $DOCUMENTATION_ROOT/contents
mkdir $DOCUMENTATION_ROOT/contents
for CONTENT in $(ls $DOCUMENTATION_ROOT/parts/contents); do

    WRITE_TO=$DOCUMENTATION_ROOT/contents/$(echo $CONTENT | cut -d_ -f2-)

    :> $WRITE_TO
    start_body >> $WRITE_TO
    cat $DOCUMENTATION_ROOT/parts/header.html >> $WRITE_TO
    cat $DOCUMENTATION_ROOT/parts/contents/$CONTENT >> $WRITE_TO
    cat $DOCUMENTATION_ROOT/parts/footer.html >> $WRITE_TO
    end_body >> $WRITE_TO

done

### Write document as a single HTML file
WRITE_TO=$DOCUMENTATION_ROOT/single.html
:> $WRITE_TO
start_body >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/header.html >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/summary.html >> $WRITE_TO

for CONTENT in $(ls $DOCUMENTATION_ROOT/parts/contents); do

    cat $DOCUMENTATION_ROOT/parts/contents/$CONTENT >> $WRITE_TO

done

cat $DOCUMENTATION_ROOT/parts/footer.html  >> $WRITE_TO
end_body >> $WRITE_TO
