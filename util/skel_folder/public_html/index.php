<?php
$currentDomain = preg_replace('/www\./i', '', $_SERVER['SERVER_NAME']);
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?php echo $currentDomain;?> | Dominio Ok!</title>
<link href="//fonts.googleapis.com/css?family=Montserrat:400,700" rel="stylesheet">
<link href="https://cdn.plen.co/assets/css/welcome.min.css" rel="stylesheet" type="text/css">
<link rel="shortcut icon" href="https://cdn.plen.co/assets/images/favicon.png" type="image/png">
<link rel="icon" href="https://cdn.plen.co/assets/images/favicon.png" type="image/png">
</head>
<body>
<div class="section">
<div id="right-block">
<div id="right-block-bottom">
<div class="right-content">
<img src="https://cdn.plen.co/icono-server.png" style="width: 200px;" title="Bienvenidos a Plen.co Hosting" alt="Bienvenidos a Plen.co Hosting">
<h2><?php echo $currentDomain;?></h2>
<h4>¡Tu cuenta de hosting ya está activa!</h4>
<p>Esta página se publicó en forma automática para indicar la correcta creación y funcionamiento de tu nueva cuenta de hosting.</p>
<p>La misma será reemplazada por tu sitio cuando lo publiques.</p>
</div>
<p class="spam-news">Consulte con su administrador en <strong>Plen.co</strong> <a href="https://plen.co">https://plen.co</a></p>
</div>
</div>
</div>
</body>
</html>
