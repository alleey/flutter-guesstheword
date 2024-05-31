import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'collection_utils.dart';

@immutable
class GroupFocusOrder extends FocusOrder {

  static const int groupAppCommands = 1;
  static const int groupButtons = 2;
  static const int groupKeys = 3;

  final int groupId;
  final int order;

  const GroupFocusOrder(this.groupId, this.order);

  @override
  int doCompare(GroupFocusOrder other) {
    if (groupId != other.groupId) {
      return groupId.compareTo(other.groupId);
    }
    return order.compareTo(other.order);
  }
}

class CustomOrderedTraversalPolicy extends FocusTraversalPolicy {

  const CustomOrderedTraversalPolicy({super.requestFocusCallback});

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    throw UnimplementedError();
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {

    final sortedNodes = _sortNodes(currentNode.enclosingScope!);
    return sortedNodes.map<FocusNode>((info) => info.node);
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {

    final sortedNodes = _sortNodes(currentNode.enclosingScope!);
    final groupedNodes = _groupNodes(sortedNodes);

    FocusNode? nextNode;

    switch (direction) {
      case TraversalDirection.up:
      case TraversalDirection.down:
        nextNode = _findNodeUpOrDown(groupedNodes, currentNode, direction);
        break;
      case TraversalDirection.left:
      case TraversalDirection.right:
        nextNode = _findNodeLeftOrRight(groupedNodes, currentNode, direction);
        break;
    }

    if (nextNode != null) {
      nextNode.requestFocus();
      return true;
    }
    return false;
  }

  FocusNode? _findNodeLeftOrRight(Map<int, List<_GroupFocusOrderNodeInfo>> groupedNodes, FocusNode currentNode, TraversalDirection direction) {

    final currentGroupId = _groupId(currentNode);
    final currrentNodeOrder = _focusOrder(currentNode)!.order;
    final siblingNodes = groupedNodes[currentGroupId]!;
    final groups = groupedNodes.keys.toList().sorted((a,b) => a.compareTo(b));

    switch (direction) {
      case TraversalDirection.left:
        final nodesLeft = CollectionUtils.splitList(siblingNodes, (item) => item.order < currrentNodeOrder ? -1 : 0).$1;
        if (nodesLeft.isNotEmpty) {
          return nodesLeft.last.node;
        }
        final nextGroup = groupedNodes[CollectionUtils.getAdjacentItem(groups, currentGroupId, false)]!;
        return nextGroup.last.node;

      case TraversalDirection.right:
        final nodesRight = CollectionUtils.splitList(siblingNodes, (item) => item.order > currrentNodeOrder ? -1 : 0).$1;
        if (nodesRight.isNotEmpty) {
          return nodesRight.first.node;
        }
        final nextGroup = groupedNodes[CollectionUtils.getAdjacentItem(groups, currentGroupId, true)]!;
        return nextGroup.first.node;

      default: break;
    }

    return null;
  }

  FocusNode? _findNodeUpOrDown(Map<int, List<_GroupFocusOrderNodeInfo>> groupedNodes, FocusNode currentNode, TraversalDirection direction) {

    final currentGroupId = _groupId(currentNode);
    final currrentNodeRect = currentNode.rect;
    final siblingNodes = groupedNodes[currentGroupId]!;
    final groups = groupedNodes.keys.toList().sorted((a,b) => a.compareTo(b));

    switch (direction) {
      case TraversalDirection.up:
        final nodesAbove = CollectionUtils.splitList(siblingNodes, (item) => _isAbove(item.node.rect, currrentNodeRect) ? -1 : 0).$1;
        if (nodesAbove.isNotEmpty) {
          final nearest = nodesAbove.map((item) => ((item.node.rect.center - currrentNodeRect.center).distance, item.node))
            .sorted((a, b) => a.$1.compareTo(b.$1))
            .first;
          return nearest.$2;
        }

        final nextGroup = groupedNodes[CollectionUtils.getAdjacentItem(groups, currentGroupId, false)]!;
        return nextGroup.last.node;

      case TraversalDirection.down:
        final nodesBelow = CollectionUtils.splitList(siblingNodes, (item) => _isBelow(item.node.rect, currrentNodeRect) ? -1 : 0).$1;
        if (nodesBelow.isNotEmpty) {
          final nearest = nodesBelow.map((item) => ((item.node.rect.center - currrentNodeRect.center).distance, item.node))
            .sorted((a, b) => a.$1.compareTo(b.$1))
            .first;
          return nearest.$2;
        }

        final nextGroup = groupedNodes[CollectionUtils.getAdjacentItem(groups, currentGroupId, true)]!;
        return nextGroup.first.node;

      default: break;
    }

    return null;
  }

  Map<int, List<_GroupFocusOrderNodeInfo>> _groupNodes(Iterable<_GroupFocusOrderNodeInfo> iterable) {
      final resultMap = <int, List<_GroupFocusOrderNodeInfo>>{};
      for (var item in iterable) {
        final groupId = item.groupId;
        if (!resultMap.containsKey(groupId)) {
          resultMap[groupId] = [];
        }
        resultMap[groupId]!.add(item);
      }
      return resultMap;
  }

  List<_GroupFocusOrderNodeInfo> _sortNodes(FocusScopeNode scope) {
    final ordered = <_GroupFocusOrderNodeInfo>[];
    for (final node in scope.traversalDescendants.toList()) {
      final order = _focusOrder(node);
      if (order != null) {
        ordered.add(_GroupFocusOrderNodeInfo.from(order, node));
      }
    }
    mergeSort(ordered, compare: (a, b) {
      return a.order.compareTo(b.order);
    });
    return ordered;
  }

  GroupFocusOrder? _focusOrder(FocusNode node) => FocusTraversalOrder.maybeOf(node.context!) as GroupFocusOrder?;
  int _groupId(FocusNode node) => _focusOrder(node)?.groupId ?? -1;
  bool _isAbove(Rect a, Rect b) => a.bottom <= b.top;
  bool _isBelow(Rect a, Rect b) => a.top >= b.bottom;

}

class _GroupFocusOrderNodeInfo extends GroupFocusOrder {
  final FocusNode node;
  const _GroupFocusOrderNodeInfo(super.groupId, super.order, {required this.node});

  factory _GroupFocusOrderNodeInfo.from(GroupFocusOrder order, FocusNode node)
    =>_GroupFocusOrderNodeInfo(order.groupId, order.order, node: node);
}
