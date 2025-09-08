resource "aws_eks_cluster" "EKS-Test" {
  name = "EKS-Test"
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = [ aws_subnet.EKS-public.id,aws_subnet.EKS-public2.id,aws_subnet.EKS-private.id, aws_subnet.EKS-private2.id ]
  }
  role_arn = aws_iam_role.eks_cluster_role.arn
}

resource "aws_eks_node_group" "EKS-node" {
    cluster_name = aws_eks_cluster.EKS-Test.name
    node_group_name = "EKS-NOdes"
    node_role_arn = aws_iam_role.eks_node_role.arn
    scaling_config {
      desired_size = 1
      max_size = 2
      min_size = 1
    }
    update_config {
      max_unavailable = 1
    }
    subnet_ids = [ aws_subnet.EKS-private2.id,aws_subnet.EKS-private.id ]
    depends_on = [
    aws_eks_cluster.EKS-Test,        # ensure cluster is created first
    aws_iam_role.eks_node_role       # ensure node role exists first
  ]

}