def application_layout
  application_html_file = <<-TEXT
  <!DOCTYPE html>
  <!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
  <!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
  <!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
  <!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  <html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Title</title>
    <meta name="description" content="This is the description">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">

    <meta property="og:title" content="Title" />
    <meta property="og:type" content="article" />
    <meta property="og:url" content="<%= root_url %>" />
    <meta property="og:image" content="<%= root_url %>/logo.png" />
    <meta property="og:description" content="This is the description" />

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
    <%= csrf_meta_tags %>
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
    <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]-->
    <!-- Google Tag Manager -->
    <noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-XXXXXX"
    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
    <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
    new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
    j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
    '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','GTM-XXXXXX');</script>
    <!-- End Google Tag Manager -->

    <%= yield %>
    
    <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  </body>
  </html>
  TEXT

  after_bundler do
    remove_file 'app/views/layouts/application.html.erb'
    create_file 'app/views/layouts/application.html.erb', application_html_file
    say_wizard "--------------------------- APPLICATION VIEWS -----------------------------"
    say_wizard "|Please change your GTM, title and meta settings in application.html.erb. |"
    say_wizard "---------------------------------------------------------------------------"
  end
end

def home_page
  after_bundler do
    generate "controller home index"
    inject_into_file "config/routes.rb", "\n  root 'home#index'", :after => "devise_for :users"
  end
end