#!/bin/sh

if [ -L $0 ]; then
    cd $(dirname $(readlink $0))
else
    cd $(dirname $0)
fi

readonly DOCUMENTATION_ROOT=$(pwd); export DOCUMENTATION_ROOT

remove_section_number () {
    cut -d_ -f2-
}

remove_extension () {
    cut -d. -f1
}

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

header_for_separate () {

    PREV_PAGE=$1
    NEXT_PAGE=$2

    echo '<header>'
    echo '  <h1>'
    echo '    <a href="index.html">Documentation Title</a>'
    echo '  </h1>'
    echo '  <div class="page-link">'
    echo "    <a class=\"page-link-prev\" href=\"$PREV_PAGE\">Previous</a>,&nbsp;"
    echo '    <a class="page-link-top" href="index.html">Top</a>,&nbsp;'
    echo "    <a class=\"page-link-next\" href=\"$NEXT_PAGE\">Next</a>"
    echo '  </div>'
    echo '</header>'
}

footer_for_separate () {

    PREV_PAGE=$1
    NEXT_PAGE=$2

    echo '<footer>'
    echo '  <div class="page-link">'
    echo "    <a class=\"page-link-prev\" href=\"$PREV_PAGE\">Previous</a>,&nbsp;"
    echo '    <a class="page-link-top" href="index.html">Top</a>,&nbsp;'
    echo "    <a class=\"page-link-next\" href=\"$NEXT_PAGE\">Next</a>"
    echo '  </div>'
    echo '</footer>'

}

generate_toc () {

    echo '<nav>'
    echo '<h2>Table of contents</h2>'
    echo '<ol>'
    for CONTENT in $(ls $DOCUMENTATION_ROOT/parts/contents); do
        echo '<li>'
        echo "<a href=\"$(echo $CONTENT | remove_section_number)\">"
        echo $CONTENT | remove_section_number | remove_extension
        echo '</a>'
        echo '</li>'
    done
    echo '</ol>'
    echo '</nav>'

}

make_array () {

    ARRAY_NAME=$1
    VALUES=$2

    COUNT=0
    for VALUE in $VALUES; do
        eval "${ARRAY_NAME}$COUNT=$VALUE"
        COUNT=$(echo $COUNT + 1 | bc)
    done

    MAX_INDEX=$(echo $COUNT - 1 | bc)
}

read_array () {

    ARRAY_NAME=$1
    INDEX=$2

    eval "echo \$${ARRAY_NAME}$INDEX"

}

### Write document as separate HTML file by content

rm -rf $DOCUMENTATION_ROOT/dist
mkdir $DOCUMENTATION_ROOT/dist

## Summary and table of contents
WRITE_TO=$DOCUMENTATION_ROOT/dist/index.html
:> $WRITE_TO
start_body >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/header.html >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/summary.html >> $WRITE_TO
generate_toc  >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/footer.html  >> $WRITE_TO
end_body >> $WRITE_TO

## Separate contents
make_array CONTENTS "$(ls $DOCUMENTATION_ROOT/parts/contents)"
CONTENTS_LAST_INDEX=$MAX_INDEX

for COUNT in $(seq 0 1 $CONTENTS_LAST_INDEX); do

    if [ $COUNT -eq 0 ]; then
        PREV=index.html
        NEXT=$(read_array CONTENTS $(echo $COUNT + 1 | bc) | remove_section_number)
    elif [ $COUNT -eq $CONTENTS_LAST_INDEX ]; then
        PREV=$(read_array CONTENTS $(echo $COUNT - 1 | bc) | remove_section_number)
        NEXT=index.html
    else
        PREV=$(read_array CONTENTS $(echo $COUNT - 1 | bc) | remove_section_number)
        NEXT=$(read_array CONTENTS $(echo $COUNT + 1 | bc) | remove_section_number)
    fi

    WRITE_TO=$DOCUMENTATION_ROOT/dist/$(read_array CONTENTS $COUNT | remove_section_number)
    :> $WRITE_TO
    start_body >> $WRITE_TO
    header_for_separate $PREV $NEXT >> $WRITE_TO
    cat $DOCUMENTATION_ROOT/parts/contents/$(read_array CONTENTS $COUNT) >> $WRITE_TO
    footer_for_separate $PREV $NEXT >> $WRITE_TO
    end_body >> $WRITE_TO

    COUNT=$(echo $COUNT + 1 | bc)

done

### Write document as a single HTML file
WRITE_TO=$DOCUMENTATION_ROOT/dist/single.html
:> $WRITE_TO
start_body >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/header.html >> $WRITE_TO
cat $DOCUMENTATION_ROOT/parts/summary.html >> $WRITE_TO

for CONTENT in $(ls $DOCUMENTATION_ROOT/parts/contents); do

    cat $DOCUMENTATION_ROOT/parts/contents/$CONTENT >> $WRITE_TO

done

cat $DOCUMENTATION_ROOT/parts/footer.html  >> $WRITE_TO
end_body >> $WRITE_TO
