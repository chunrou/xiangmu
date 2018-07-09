const gulp = require('gulp') // gulp主文件
const minjs = require('gulp-uglify'); // js压缩
const minCSS = require('gulp-clean-css'); // css压缩
const sass = require('gulp-sass'); // scss编译成css
const rename = require('gulp-rename'); // 重命名工具

// task-任务 （‘任务名称’，任务方法）
gulp.task('g_sass', function(){
    // 执行方法对象的路径
    gulp.src('./src/css/*.scss')
    // pipe是通道，找到目标后执行对应方法
    .pipe(sass()) // 如编译 
    .pipe(minCSS())
    .pipe(gulp.dest('./dist/css')) // dest是编译后的地址
});
// watch是监听文件变化
gulp.watch('./src/css/*.scss', function(){
    gulp.run('g_sass'); // 执行任务
})


gulp.task('g_js', function(){
    // 执行方法对象的路径
    gulp.src('./src/js/*.js')
    // pipe是通道，找到目标后执行对应方法 
    // .pipe(minjs())
    .pipe(gulp.dest('./dist/js')) // dest是编译后的地址
    // .pipe(rename({suffix: '.min'}))
    // .pipe(gulp.dest('./dist/js'))
});
gulp.watch('./src/js/*.js', function(){
    gulp.run('g_js');
})

gulp.task('g_html', function(){
    gulp.src('./src/html/*.html')
    .pipe(gulp.dest('./dist/html'))
});
gulp.watch('./src/html/*.html', function(){
    gulp.run('g_html'); // 执行任务
})

gulp.task('g_html2', function(){
    gulp.src('./src/*.html')
    .pipe(gulp.dest('./dist'))
});
gulp.watch('./src/*.html', function(){
    gulp.run('g_html2'); // 执行任务
})

gulp.task('default', ['g_sass', 'g_js', 'g_html', 'g_html2']);
// default 默认 ， 【】执行方法的队列