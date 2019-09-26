<!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=5,IE=9" ><![endif]-->
<!DOCTYPE html>
<%@ page contentType="text/html; charset=UTF-8" %>
<html>
<head>
    <title>Grapheditor</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" type="text/css" href="graph/lib/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="graph/styles/grapheditor.css">
    <script type="text/javascript">
        // Parses URL parameters. Supported parameters are:
        // - lang=xy: Specifies the language of the user interface.
        // - touch=1: Enables a touch-style user interface.
        // - storage=local: Enables HTML5 local storage.111
        // - chrome=0: Chromeless mode.
        var urlParams = (function(url)
        {
            var result = new Object();
            var idx = url.lastIndexOf('?');

            if (idx > 0)
            {
                var params = url.substring(idx + 1).split('&');

                for (var i = 0; i < params.length; i++)
                {
                    idx = params[i].indexOf('=');

                    if (idx > 0)
                    {
                        result[params[i].substring(0, idx)] = params[i].substring(idx + 1);
                    }
                }
            }

            return result;
        })(window.location.href);

        // Default resources are included in grapheditor resources
        mxLoadResources = false;
    </script>
    <script type="text/javascript" src="graph/js/Init.js"></script>
    <script type="text/javascript" src="graph/deflate/pako.min.js"></script>
    <script type="text/javascript" src="graph/deflate/base64.js"></script>
    <script type="text/javascript" src="graph/jscolor/jscolor.js"></script>
    <script type="text/javascript" src="graph/sanitizer/sanitizer.min.js"></script>
    <script type="text/javascript" src="graph/js/mxClient.js"></script>
    <script type="text/javascript" src="graph/js/EditorUi.js"></script>
    <script type="text/javascript" src="graph/js/Editor.js"></script>
    <script type="text/javascript" src="graph/js/Sidebar.js"></script>
    <script type="text/javascript" src="graph/js/Graph.js"></script>
    <script type="text/javascript" src="graph/js/Format.js"></script>
    <script type="text/javascript" src="graph/js/Shapes.js"></script>
    <script type="text/javascript" src="graph/js/Actions.js"></script>
    <script type="text/javascript" src="graph/js/Menus.js"></script>
    <script type="text/javascript" src="graph/js/Toolbar.js"></script>
    <script type="text/javascript" src="graph/js/Dialogs.js"></script>
</head>
<body class="geEditor">
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">echarts配置</h4>
                </div>
                <div class="modal-body" id="contentConfig">
                    <!--内容-->
                    <input type="checkbox" name="isStyle">是否添加填充样式
                    <table>
                        <tr>
                            <td style="width: 40px"><input style="width: 40px" type="text"  Placeholder="长度" readonly="readonly"/></td>
                        </tr>
                        <tr>
                            <!-- name="5" -->
                            <td style="width: 40px"><input style="width: 40px" type="text" name="7"/></td>
                        </tr>
                    </table>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="Determine">确定</button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="graph/lib/jquery.js"></script>
    <script type="text/javascript" src="graph/lib/echarts.min.js"></script>
    <script type="text/javascript" src="graph/lib/bootstrap.min.js"></script>
    <script type="text/javascript">
        // Extends EditorUi to update I/O action states based on availability of backend
        (function()
        {
            var editorUiInit = EditorUi.prototype.init;

            EditorUi.prototype.init = function()
            {
                var myChart =
                    echarts.init($('#echartS')[0]);
                option = {
                    xAxis: {
                        type: 'category',
                        boundaryGap: false,
                        data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    },
                    yAxis: {
                        type: 'value'
                    },
                    series: [{
                        data: [820, 932, 901, 934, 1290, 1330, 1320],
                        type: 'line',
                        areaStyle: {}
                    }]
                };
                // 使用刚指定的配置项和数据显示图表。
                myChart.setOption(option);
                //================
                editorUiInit.apply(this, arguments);
                this.actions.get('export').setEnabled(false);

                // Updates action states which require a backend
                if (!Editor.useLocalStorage)
                {
                    mxUtils.post(OPEN_URL, '', mxUtils.bind(this, function(req)
                    {
                        var enabled = req.getStatus() != 404;
                        this.actions.get('open').setEnabled(enabled || Graph.fileSupport);
                        this.actions.get('import').setEnabled(enabled || Graph.fileSupport);
                        this.actions.get('save').setEnabled(enabled);
                        this.actions.get('saveAs').setEnabled(enabled);
                        this.actions.get('export').setEnabled(enabled);

                    }));
                }
            };

            // Adds required resources (disables loading of fallback properties, this can only
            // be used if we know that all keys are defined in the language specific file)
            mxResources.loadDefaultBundle = false;
            var bundle = mxResources.getDefaultBundle(RESOURCE_BASE, mxLanguage) ||
                mxResources.getSpecialBundle(RESOURCE_BASE, mxLanguage);

            // Fixes possible asynchronous requests
            mxUtils.getAll([bundle, STYLE_PATH + '/default.xml'], function(xhr)
            {

                // Adds bundle text to resources
                mxResources.parse(xhr[0].getText());

                // Configures the default graph theme
                var themes = new Object();
                themes[Graph.prototype.defaultThemeName] = xhr[1].getDocumentElement();

                // Main
                new EditorUi(new Editor(urlParams['chrome'] == '0', themes));
            }, function()
            {
                document.body.innerHTML = '<center style="margin-top:10%;">Error loading resource files. Please check browser console.</center>';
            });

        })();

    </script>
</body>
</html>

