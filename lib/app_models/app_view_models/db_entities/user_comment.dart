class UserComment {
  int commentId;
  String shortComment;
  String comment;

  UserComment(this.commentId, this.shortComment, this.comment);

  String get dropdownText => shortComment;
}
