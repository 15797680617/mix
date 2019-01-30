<!DOCTYPE html>
<%@ page language="java" import="java.util.*" pageEncoding="utf-8" %>
<%@ page contentType="text/html;charset=utf-8" %>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html charset=UTF-8">
    <title>接口调试</title>
    <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
    <script src="https://cdn.staticfile.org/vue-resource/1.5.1/vue-resource.min.js"></script>
    <!-- 新 Bootstrap 核心 CSS 文件 -->
    <link href="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.staticfile.org/jquery/2.1.1/jquery.min.js"></script>
    <script src="https://cdn.staticfile.org/twitter-bootstrap/3.3.7/js/bootstrap.min.js"></script>

</head>
<body>

<div id="ContextPath" val="<%=request.getContextPath()%>">
</div>

<div id="app">
    <h2 style="text-align: center;">接口调试工具</h2>
    <div class="panel-group" id="cord0" style="width: 80%;margin: auto;">

        <!--Package层-->
        <div class="panel panel-default" v-for="p in packageList">
            <div class="panel-heading">
                <h4 class="panel-title">
                    <a data-toggle="collapse" data-parent="#cord0"
                       :href="'#'+p.id" style="font-size: 28px;">
                        {{p.packageName}}
                    </a>
                </h4>
            </div>
            <div :id="p.id" class="panel-collapse collapse">
                <div class="panel-body">

                    <!--Controller层-->
                    <div class="panel-group" :id="'cord'+p.id">
                        <div class="panel panel-success" v-for="c in p.controlVoList">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <a data-toggle="collapse" :data-parent="'#cord'+p.id"
                                       :href="'#'+c.id">
                                        {{c.url}}
                                    </a>
                                </h4>
                            </div>
                            <div :id="c.id" class="panel-collapse collapse">
                                <div class="panel-body">

                                    <!--方法层-->
                                    <div class="panel-group" :id="'cord'+c.id">
                                        <div class="panel panel-info" v-for="m in c.methodVOS">
                                            <div class="panel-heading">
                                                <h4 class="panel-title">
                                                    <a data-toggle="collapse" :data-parent="'#cord'+c.id"
                                                       :href="'#'+m.id" @click="changeMethod(m)">
                                                        {{m.url}}
                                                    </a>
                                                </h4>
                                            </div>
                                            <div :id="m.id" class="panel-collapse collapse">
                                                <div class="panel-body">

                                                    <table class="table table-striped" :id="m.id">
                                                        <thead>
                                                        <tr>
                                                            <th style="width: 20%;">参数名</th>
                                                            <th>参数值</th>
                                                            <th>参数类型</th>
                                                        </tr>
                                                        </thead>
                                                        <tbody>
                                                        <tr v-for="p in m.parameters">
                                                            <td>
                                                                <input :value="p.name" readonly class="form-control" style="width: 100%;">
                                                            </td>
                                                            <td>
                                                                <input type="file" v-if="p.file" multiple class="form-control">
                                                                <input v-else style="width: 100%;" class="form-control">
                                                            </td>
                                                            <td>
                                                                {{p.typeName}}
                                                            </td>
                                                        </tr>
                                                        </tbody>
                                                    </table>

                                                    <button type="button" class="btn btn-primary"
                                                            style="margin-top: 16px;"
                                                            @click="onRequest(this)">发起请求
                                                    </button>

                                                    <button type="button" class="btn btn-warning"
                                                            style="margin-top: 16px;"
                                                            @click="formReset(this)">重置表单
                                                    </button>

                                                    <button type="button" class="btn btn-info" style="margin-top: 16px;"
                                                            @click="appendParameter(this)">追加参数</button>

                                                    <select :id="'reqType'+m.id" class="form-control"
                                                            style="display: inline;width: 6%;vertical-align: bottom;">
                                                        <option value="GET">Get</option>
                                                        <option value="POST" selected>Post</option>
                                                    </select>

                                                    <hr/>
                                                    响应结果：
                                                    <iframe v-if="m.file" :id="'respFrame'+m.id" :name="'respFrame'+m.id" style="display: block;width: 100%;"></iframe>
                                                    <pre v-else :id="'resp'+m.id" style="white-space: pre-wrap;"> </pre>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
</body>
</html>

<script>
    var app = new Vue({
        el: '#app',
        data: {
            controlList: [],
            packageList: [],
            currentMethod: null,
            ContextPath: '<%=request.getContextPath()%>'
        },
        mounted() {
            const me = this
            this.$http.get('ts/getUrl').then(function (res) {
                console.info(res);
                me.packageList = res.body;
                let index = 0;
                me.packageList.forEach(p => {
                    p.id = 'p' + index++;
                    var index1 = 1;
                    p.controlVoList.forEach(c => {
                        c.id = 'c' + index++;
                        c.methodVOS.forEach(m => {
                            m.id = 'm' + index++;
                            m.parameters.forEach(pm=>{
                                if (pm.file) {
                                    m.file = true;
                                }
                            })
                        })
                    });
                })
            });
        },
        methods: {
            onRequest(btn) {
                const me = this;
                const m = me.currentMethod;
                const trs = $("#" + m.id + " tbody tr");
                const data = {};
                let isFile = false;
                trs.each(function (index,e) {
                    const ips = $(e).find('input');
                    const key = ips[0].value;
                    const value = ips[1].value;
                    if (key != null && key != '' && value!=null && value!='') {
                        data[key] = value;
                    }
                    if (ips[1].type == 'file') {
                        isFile = true;
                        return;
                    }
                });

                if (isFile) {
                    me.onRequestFile();
                    return;
                }
                $('#resp' + m.id).html('正在请求，请稍等...');
                $.ajax({
                    //项目根路径 需自行修改（后续版本会实现自动化）
                    url: me.ContextPath + m.url,
                    method: $('#reqType' + m.id)[0].value,
                    dataType: 'json',
                    data: data,
                    success: function (res) {
                        $('#resp' + m.id).html(JSON.stringify(res, null, 2));
                    },
                    error: function (res) {
                        $('#resp' + m.id).html('<span style="color: red;">' + JSON.stringify(res, null, 2) + '</span>');
                    }
                });
            },
            onRequestFile(){
                const me = this;
                const m = me.currentMethod;
                const trs = $("#" + m.id + " tbody tr");
                const form = $("<form method='post' target='respFrame"+m.id+"'></form>");
                form.attr({
                    'action':me.ContextPath+m.url,
                    'enctype':'multipart/form-data'
                });
                let input;
                trs.each((index, e) => {
                    const ips = $(e).find('input');
                    const key = ips[0].value;
                    const value = ips[1].value;
                    if (key != null && key != '' && value!=null && value!='') {
                        input = $(ips[1]).clone(true);
                        input.attr({"name":key});
                        form.append(input);
                    }
                });
                $(document.body).append(form);
                form.submit();
                form.remove();
            },
            changeMethod(m) {
                this.currentMethod = m;
            },
            formReset() {
                const me = this;
                const m = me.currentMethod;
                const trs = $("#" + m.id + " tbody tr");
                trs.each(function (index,e) {
                    const ips = $(e).find('input');
                    $(ips[1]).val(null)
                });
            },
            appendParameter(btn){
                const me = this;
                const m = me.currentMethod;
                const t = $("#"+m.id+" tbody");
                t.append('<tr><td><input style="width: 100%;" class="form-control"></td><td><input style="width: 100%;" class="form-control"></td><td></td></tr>');
            }
        }
    })
</script>