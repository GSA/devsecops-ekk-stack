output "test_instance_ip" {
    value = "${aws_instance.stream_tester.public_ip}"
}