<template>
    <div class="container">
      <el-button color="var(--main-color)" size="large" @click="this.optionsAdd = true" >Thêm tài khoản mới</el-button>
     
      <el-table 
        :data="filterUser" 
        :default-sort="{ prop: 'AccountID', order: 'ascending' }"
        empty-text="Không có dữ liệu"
      >
  
      <el-table-column label="ID" prop="AccountID" width="150" sortable/>
      <el-table-column label="Tài khoản" prop="UserName" />
      <el-table-column label="Email" prop="Email" />
      <el-table-column 
        label="Vai trò" 
        prop="RoleID" 
        :filters="[
            { text: 'Sinh viên', value: '3' },
            { text: 'Giáo viên', value: '2' },
            { text: 'Admin', value: '1' },
        ]"
        :filter-method="filterHandler"
        >
        <template #default="scope">
          <el-tag
            :type="this.handleTypeTableRole(scope.row.RoleID)"
            >{{ this.handleTableNameRole(scope.row.RoleID) }} 
          </el-tag> 
        </template> 
      </el-table-column>
      
      <el-table-column>
  
        <template #header>
          <el-input v-model="search" size="large" placeholder="Tìm kiếm tài khoản" clearable>
        </el-input>
        </template>
  
        <template #default="scope">
          <el-button
            size="large"
            type="danger"
            @click="handleDeleteUser(scope.row.AccountID)"
            >Xóa
          </el-button>
        </template>
  
      </el-table-column>
    </el-table>


    <el-dialog v-model="optionsAdd" title="Chọn hình thức thêm" width="40%">
      <div class="options-container">
        <div class="option-area">
          <el-button type="success" @click="openWith('excel')">
            <v-icon class="option-icon">mdi-microsoft-excel</v-icon>
            Thêm qua excel
          </el-button>
        </div>
      </div>
  </el-dialog>


  <!-- Add By Excel -->
  <template>
    <el-dialog
        v-model="addByExcel"
        width="50%"
        title="Thêm bằng Excel"
        append-to-body
      >

      <el-upload
        class="upload-demo"
        drag
        :auto-upload="false"
        :limit="1"
        :action="''"
        :on-change="handleUpload"
        :before-upload="beforeUpload"
      >
        <v-icon style="font-size: 80px;">mdi-progress-upload</v-icon>

        <div class="el-upload__text">
          Thả file ở đây hoặc <em>chọn file</em>
        </div>

        <template #tip>
          <div class="el-upload__tip">
            Chỉ chọn 1 file (dạng xls)
          </div>
        </template>


      </el-upload>

      
      <el-switch
          v-model="typeUser"
          size="large"
          active-text="Dữ liệu là giáo viên "
          inactive-text="Dữ liệu là sinh viên"
        />

      <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="Account" label="Tài khoản"></el-table-column>
      <el-table-column prop="Email" label="Email"></el-table-column>
      <el-table-column prop="Password" label="Password"></el-table-column>
    </el-table>

     <template #footer>
        <div class="dialog-footer">
          <el-button color="var(--main-color)" size="large" @click="addNewUserByExcel()" > Thêm </el-button>
        </div>
      </template>

    </el-dialog>
  </template>

  <!-- Add By default -->
  <template>
    <el-dialog
        v-model="addByDefault"
        width="50%"
        title="Thêm thủ công"
        append-to-body
      >
     
      <el-input v-model="inputNewUsername" size="large" placeholder="Nhập tài khoản" />
      <el-input v-model="inputNewPassword" size="large" placeholder="Nhập mật khẩu" />
      <el-input v-model="inputNewEmail" size="large" placeholder="Nhập email" />

      
      <div>
        <el-select  v-model="value"  placeholder="Quyền truy cập" size="large" clearable >
        <el-option
          v-for="item in optionsRole"
          :key="item.value"
          :label="item.label"
          :value="item.value"
        />
      </el-select>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" size="large" @click="addNewUserByDefault()"> Thêm </el-button>
        </div>
      </template>


    </el-dialog>
  </template>
  
  
  
    <AskBox 
        v-if="showAskBox"
        :title="'Bạn có muốn xóa tài khoản này ?'"
        :typeButton="'danger'"
        :btnYes="'Xóa'"
        @confirm="deleteUser"
        @close="this.showAskBox = false"
    />
  
    <ConfirmPassword v-if="showAuthenBox"
        @authenticate="handleAuthenticate"
    />
  
    </div>
  </template>
  
  <script>
  import axiosInstance from '../axios'
  import ConfirmPassword from '@/components/ConfirmPassword.vue';
  import AskBox from '@/components/AskBox.vue'
  import Cookies from 'js-cookie';
  import { ElNotification } from 'element-plus'
  import { requireTokenMixin } from '@/mixin/requireTokenMixin'
  import * as XLSX from 'xlsx';

    export default {
      mixins:[requireTokenMixin],
      components: {AskBox, ConfirmPassword},
      data () {
        return {
          search: '',
          idTeacher: '',
          searchString: "",
          dialog: false,
  
          dataClass: [],
          facultyList: [],
          idClassDelete: '',
          teacherList: [],
          showAskBox: false,
          showSelectTeacherFaculty: false,
  
  
          // ----
          dataUsersAPI: [],
          inputTopicName: '',
          inputTopicDescribe: '',
          optionsAdd: false,
          addByExcel: false,
          addByDefault: false,
          tableData: [],

          typeUser: false,

          inputNewEmail: '',
          inputNewPassword: '',
          inputNewRoleID: '1',
          inputNewUsername: '',

          idNeedDelete: '',

          showAuthenBox: false,

          optionsRole: [
            {
              value: 'admin',
              label: 'Admin',
            },
            {
              value: 'user',
              label: 'Sinh viên',
            },
            {
              value: 'teacher',
              label: 'Giáo viên',
            },
          ] 
        }
          
      },

      computed: {
        filterUser(){
          if (!this.search) {
            return this.dataUsersAPI.flatMap(user => user).filter(user => user.Active === true)
          }
          return this.dataUsersAPI.flatMap(user => user).filter(user => user.UserName.toLowerCase().includes(this.search.toLowerCase()));
        }
      },    
  
      mounted(){
        this.changeTitle()
        this.getAllUsers()
  
      },
  
      methods:{
        changeTitle(){
          document.title = "Quản lý tài khoản"
        },

        showNotification(title ,message, type){
            ElNotification({
                title: `${title}`,
                message: `${message}`,
                type: `${type}`,
            })
        },
  
        //lấy topic theo id user
        getAllUsers(id){
            axiosInstance.get('getAllUsers')
            .then((res) => {
                this.dataUsersAPI.length = 0
                this.dataUsersAPI.push(res.data)
            })
        },

        handleTypeTableRole(role){
            if(role == 1){
                return 'success'
            }
            else if(role == 2){
                return 'danger'
            }
            else{
                return 'primary'
            }
        },

        handleTableNameRole(role){
            if(role == 1){
                return 'Admin'
            }
            else if(role == 2){
                return 'Giáo viên'
            }
            else{
                return 'Sinh Viên'
            }
        },

        handleAuthenticate(statusAuthen){

          if(statusAuthen == true){
            this.showAuthenBox = false
            this.showNotification('Thông báo', 'Xác thực thành công', 'success')
            this.handleAddNewUser()
          }else{
            this.showAuthenBox = false
            this.showNotification('Thông báo', 'Xác thực thất bại', 'error')
            this.typeUser =false
          }          
        },

        
        filterHandler(value, row){
             return row.RoleID == value 
        },

        openWith(typeOpen){
            if(typeOpen == 'excel'){
              this.addByExcel = true
            }
            else{
              this.addByDefault = true
            }
        },

        loadUploadedFile(file){
            console.log(file)
        },

        handleDeleteUser(idChoose){
          this.idNeedDelete = idChoose
          this.showAskBox = true
          
        }, 

        async deleteUser(){
          try{
              let result = await axiosInstance.delete(`/DeleteUser/${this.idNeedDelete}`)
              if(result.status == 200) {
                this.showNotification('Thông báo', 'Xóa thành công', 'success')
                this.showAskBox = false
                this.getAllUsers()
              }       

          }
          catch{
            this.showNotification('Thông báo', 'Xóa không thành công', 'error')
          }

        },  

        async addNewUserByDefault(){
          let result = await axiosInstance.post('/addNewUser',{
              "Username": `${this.inputNewUsername}`,
              "Password": `${this.inputNewPassword}`,
              "Email": `${this.inputNewEmail}`,
              "RoleID": `${this.inputNewRoleID}`
          })

          if(result.status == 200){
              this.showNotification('Thông báo', 'Thêm tài khoản mới thành công', 'success')
              this.getAllUsers()
              this.inputNewEmail = this.inputNewPassword = this.inputNewUsername = ''
          }

        },

        async addNewUserByExcel(){  
          //1: ADMIN, 2: GIAO VIEN, 3: SINH VIEN

          if(this.tableData.length > 0 ){
            let convertTypeUser = this.typeUser == false ? 3 : 2

            if(convertTypeUser == 2)
              {
                this.showAuthenBox = true
              }
            else{
              this.handleAddNewUser()
            }
          }
          else{
            this.$message.error('Dữ liệu excel chưa import.');
          }
           
        },

        async handleAddNewUser(){
          let showNotificationFlag = false;

          for (let i = 0; i < this.tableData.length; i++){
            let convertTypeUser = this.typeUser == false ? 3 : 2

              try{
                  let result = await axiosInstance.post('/addNewUser',{
                    "Username": `${this.tableData[i].Account}`,
                    "Password": `${this.tableData[i].Password}`,
                    "Email": `${this.tableData[i].Email}`,
                    "RoleID": convertTypeUser
                  })

                  if(result.status == 200) {
                    this.addByExcel = false
                    this.optionsAdd = false 
                    this.getAllUsers()
                    
                    if (!showNotificationFlag) {
                      this.showNotification('Thông báo', 'Thêm thành công', 'success');
                      showNotificationFlag = true; // Đánh dấu thông báo đã được hiển thị
                    }
                  }

                }
              catch(error){
                if (!showNotificationFlag) {
                  this.showNotification('Thông báo', 'Thêm không thành công', 'error');
                  showNotificationFlag = true; // Đánh dấu thông báo đã được hiển thị
                }
              }
            }    
        },

        addTypeUser(data){
            console.info("data", data)

        },

        // ------------------
        
        getDataLocalStorage(){
            let dataUser = JSON.parse(Cookies.get('userInfo'))
            this.getDataTopic(dataUser.accountID)
        },

        // Handle upload file 
        handleUpload(file) {
          const reader = new FileReader()
          reader.onload = (e) => {
            const data = new Uint8Array(e.target.result)
            const workbook = XLSX.read(data, { type: 'array' })
            const sheetName = workbook.SheetNames[0]
            const worksheet = workbook.Sheets[sheetName]
            const jsonData = XLSX.utils.sheet_to_json(worksheet)
            this.tableData = jsonData
          }
          reader.readAsArrayBuffer(file.raw)
        },
        
        //handle file is excel or not
        beforeUpload(file) {
          const isExcel =
            file.type === 'application/vnd.ms-excel' ||
            file.type ===
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          if (!isExcel) {
            this.showNotification('Hệ thống','Chỉ chấp nhận định dạng Excel', 'error')
          }
          return isExcel
        },
  
        // ---------------
  
   
        getAllClasses(){
          axiosInstance.get('SelectAllClasses')
              .then(res => this.handleData(res.data))
        },
  
  
        //set data for v-table
        handleData(data){        
          this.dataClass.length =0
            this.dataClass.push(...data)
        },
  
        handleDeleteClass(idClassChoose){
          this.idClassDelete = idClassChoose
          this.showAskBox = true
        },
  
        async deleteClass(){
  
          let result = await axiosInstance.delete(`/DeleteClass/${this.idClassDelete}`)
              
          if (result.status == 200) {
            this.getAllClasses()
            this.showAskBox = false
            this.showNotification('Thông báo', 'Xóa thành công', 'error')
          }
         
        },
        handleABC(index, row){
          console.log("chạy nè",index, row)
  
            console.log(index,row)
        },
  
  
  
        addNewClass(){
          this.dialog = true
        },
  
        getAllFaculty(){
          // add faculty name to v-select
          axiosInstance.get('SelectAllFaculty')
              .then((res) => {
                for(let i = 0; i < res.data.length; i++){
                  this.facultyList.push(res.data[i].FacultyName)
                }
              })
        },
        
        selectFaculty(data){
          this.showSelectTeacherFaculty = true
          axiosInstance.post(`getTeacherByFaculty/${data}`)
          .then((res)=> {
            this.teacherList.length = 0
            for(let i = 0; i < res.data.length; i++){
                this.teacherList.push(res.data[i].Name)
            
             }
          })
           
        },
  
        handleEdit(index, row){
          console.log("chạy nè",index, row)
        },
  

  
        
      }
    }
  </script>
  
  
  <style lang="scss" scoped>
  .container{
    height: 100vh;
  }
 
  .el-dialog{
  
    .el-input + .el-input{
      margin-top: 20px;
    }
  }

  .options-container{
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100% ;
    height: 200px;
  }

  .option-area{
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 50px;


    .el-button{
      width: 100%;
      height: 100%;
    }

    .option-icon{
      font-size: 50px;
     
    }
  }

  .el-select{
    margin-top: 20px;
    width: 100%;
  }

  .dialog-footer{


    .el-button{
      width: 100%;
    }
  }
  
  
  
  
  </style>