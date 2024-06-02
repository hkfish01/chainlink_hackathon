
# 项目名称
 chainlink hackathon frontend
 
## 目录
- [项目名称](#项目名称)
  - [目录](#目录)
  - [简介](#简介)
  - [项目结构](#项目结构)
  - [安装与运行](#安装与运行)
    - [本地启动](#本地启动)
    - [生产部署](#生产部署)
  - [脚本说明](#脚本说明)
  - [技术栈](#技术栈)
  - [许可证](#许可证)

## 简介
项目名称是一个基于Vue.js构建的前端应用。本项目采用了Vue CLI进行脚手架搭建。

## 项目结构
项目根目录
├── public/ // 静态资源
├── src/ // 源代码
│ ├── assets/ // 资源文件
│ ├── libs/ // 第三方库
│ ├── views/ // 视图文件
│ ├── router/ // 路由配置
│ ├── x/ // 中间件、api、工具类
│ ├── App.vue // 根组件
│ └── main.js // 入口文件
├── .gitignore // Git忽略文件配置
├── babel.config.js // Babel配置
├── package.json // 项目依赖及脚本
├── README.md // 项目说明文件
└── vue.config.js // Vue CLI 配置



## 安装与运行

### 本地启动
1. **克隆仓库**
   ```bash
   git clone git@github.com:hkfish01/chainlink_hackathon.git
   cd chainlink_hackathon/frontend
   ```
   
2. **安装依赖**
   ```bash
   npm install
   ```
   
3. **启动项目**
   ```bash
   npm run serve
   ```
   
4. **访问项目**
   ```bash
   http://localhost:8080
   ```
   
### 生产部署
1. **构建项目**
   ```bash
   npm run build
   ```
   
2. **部署到服务器**
   ```
    将生成的dist目录中的文件上传到你的服务器，你的Web服务器的根目录下。
    例如： /root/chainlink-frontend/dist;
    
   ```
3. **nginx 配置**

    ```
    location / {
        root   /root/chainlink-frontend/dist;
        try_files $uri $uri/ /index.html;
        index  index.html index.htm;
    }
    location /prod-api/ {
      # 这里需要配置你的后端服务地址
      proxy_pass http://localhost:8088/;
    }
    ```

## 脚本说明
 在package.json中定义了以下脚本：
```bash
  npm run serve：启动本地开发服务器。
  npm run build：构建生产环境的静态文件。
  npm run lint：运行ESLint检查代码。
```

## 技术栈
- [Vue.js](https://vuejs.org/) - 渐进式JavaScript框架
- [Vue Router](https://router.vuejs.org/) - Vue.js官方路由管理器
- [Vuex](https://vuex.vuejs.org/) - 状态管理模式
- [Axios](https://axios-http.com/) - 基于Promise的HTTP客户端

## 许可证
本项目基于MIT许可证进行发布。

