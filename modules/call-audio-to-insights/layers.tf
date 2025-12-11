resource "null_resource" "pip_install" {
  # Triggers a rebuild when requirements.txt changes by hashing the file content
  triggers = {
    requirements_hash = sha256(file("${path.module}/lambdas/requirements.txt"))
  }

  provisioner "local-exec" {
    # Command to install requirements into the local "python" directory
    # Note: For cross-platform compatibility, especially with libraries like NumPy,
    # it's best practice to build in a Linux environment (e.g., Docker).
    # The example below assumes a compatible Linux environment or simple dependencies.
    command = "pip3 install -r ${path.module}/lambdas/requirements.txt -t ${path.module}/layers/python"
  }
}

data "archive_file" "requierements" {
  depends_on  = [null_resource.pip_install]
  type        = "zip"
  source_dir  = "${path.module}/layers/python"
  output_path = "${path.module}/build/python.zip"
}

resource "aws_lambda_layer_version" "requirements" {
  filename            = data.archive_file.requierements.output_path
  layer_name          = "${var.project}-post-${random_id.suffix.hex}"
  compatible_runtimes = ["python3.11", "python3.12"]
  source_code_hash    = data.archive_file.requierements.output_base64sha256
}
