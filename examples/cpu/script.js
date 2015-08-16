function lineGraph() {
    var selection = null,
        data = null,
        margin = {top: 20, right: 20, bottom: 30, left: 50};

    function draw() {
        if (selection == null) {
            return console.log('no selection');
        }
        else if (data == null) {
            return console.log('no data');
        }

        console.log('running layout...');

        d3.select(selection).selectAll('*').remove();

        var xMin = 0,
            xMax = data.length - 1;

        var yMin = d3.min(data, function (x) { return x; }),
            yMax = d3.max(data, function (x) { return x; });

        var width = $(selection).width() - margin.left - margin.right,
            height = $(selection).height() - margin.top - margin.bottom;

        var xScale = d3.scale.linear()
            .domain([xMin, xMax])
            .range([0, width]);

        var yScale = d3.scale.linear()
            .domain([yMin, yMax])
            .range([height, 0]);

        var xAxis = d3.svg.axis()
            .scale(xScale)
            .orient('bottom');

        var yAxis = d3.svg.axis()
            .scale(yScale)
            .orient('left');

        var chart = d3.select(selection).append('svg')
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        chart.append('g')
            .attr('class', 'xaxis')
            .attr('transform', 'translate(0,' + height + ')')
            .call(xAxis);

        chart.append("g")
          .attr("class", "y axis")
          .call(yAxis);

        var line = d3.svg.line()
            .x(function(x, i) { return xScale(i); })
            .y(function(x) { return yScale(x); });

        var path = chart.append('path')
            .datum(data)
            .attr('class', 'line')
            .attr('d', line);
    }

    draw.selection = function(value) {
        if (!arguments.length) return selection;
        selection = value;
        return draw;
    };

    draw.data = function(value) {
        if (!arguments.length) return data;
        data = value;
        return draw;
    };

    return draw;
}
