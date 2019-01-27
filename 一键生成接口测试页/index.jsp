<!DOCTYPE html>
<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ page contentType="text/html;charset=utf-8"%>
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

<div id="app">
    <h2 style="text-align: center;">接口调试工具</h2>
    <div class="panel-group" id="cord0" style="width: 80%;margin: auto;">
        <div class="panel panel-success" v-for="c in controlList">
            <div class="panel-heading">
                <h4 class="panel-title">
                    <a data-toggle="collapse" data-parent="#cord0"
                       :href="'#'+c.id">
                        {{c.url}}
                    </a>
                </h4>
            </div>
            <div :id="c.id" class="panel-collapse collapse">
                <div class="panel-body">

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

                                    <form class="form-inline" role="form" :id="m.url">
                                        <lanel v-for="p in m.parameters">
                                            {{p}}：<input type="text" :name="p" class="form-control" placeholder="请输入">&nbsp;
                                        </lanel>
                                    </form>

                                    <button type="button" class="btn btn-primary" style="margin-top: 16px;"
                                            @click="onRequest(this)">发起请求</button>

                                    <select :id="'reqType'+m.id" class="form-control" style="display: inline;width: 6%;vertical-align: bottom;">
                                        <option value="GET">Get</option>
                                        <option value="POST" selected>Post</option>
                                    </select>

                                    <hr />
                                    响应结果：
                                    <pre :id="'resp'+m.id" style="white-space: pre-wrap;"> </pre>
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
            controlList:[],
            currentMethod:null
        },
        mounted () {
            const me = this
            this.$http.get('ts/getUrl').then(function(res){
                console.info(res);
                me.controlList = res.body;
                var index = 1;
                me.controlList.forEach(item=>{
                    item.id = 'out'+index;
                    var index1 = 1;
                    item.methodVOS.forEach(i=>{
                        i.id = index +'in'+ index1++;
                    })
                    index++;
                })
            });
        },
        methods:{
            onRequest(btn) {
                const me = this;
                const m = me.currentMethod;
                const form = $(document.getElementById(m.url));
                const arr = form.serializeArray();
                const data = {};
                arr.forEach(item=>{
                    data[item.name] = item.value;
                })
                $('#resp' + m.id).html('正在请求，请稍等...');
                $.ajax({
                    //项目根路径 需自行修改（后续版本会实现自动化）
                    url: '/xwrcisvr_cs'+m.url,
                    method: $('#reqType'+m.id)[0].value,
                    dataType: 'json',
                    data:data,
                    success: function(res) {
                        $('#resp' + m.id).html(JSON.stringify(res, null, 2));
                    },
                    error:function (res) {
                        $('#resp' + m.id).html('<span style="color: red;">'+JSON.stringify(res, null, 2)+'</span>');
                    }
                });
            },
            changeMethod(m){
                this.currentMethod = m;
            }
        }
    })
</script>