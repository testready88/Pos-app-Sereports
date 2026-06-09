// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/category/category_bloc.dart';
import 'package:sereports/bloc/category/category_state.dart';
import 'package:sereports/bloc/subcategory/sub_category_bloc.dart';
import 'package:sereports/bloc/subcategory/sub_category_event.dart';
import 'package:sereports/bloc/subcategory/sub_category_state.dart';
import 'package:sereports/constants.dart';

class SubCategoryDropdown extends StatefulWidget {
  const SubCategoryDropdown({Key? key}) : super(key: key);

  @override
  State<SubCategoryDropdown> createState() => _SubCategoryDropdownState();
}

class _SubCategoryDropdownState extends State<SubCategoryDropdown> {
  bool _isDropdownOpen = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Setup search input listener with debounce
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // Get the current category code
      final categoryState = context.read<CategoryBloc>().state;
      String categoryCode = '';
      if (categoryState is CategoryLoaded) {
        categoryCode = categoryState.selectedCategoryCode;
      }

      context.read<SubCategoryBloc>().add(
            LoadSubCategories(
              categoryCode: categoryCode,
              searchText: _searchController.text,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubCategoryBloc, SubCategoryState>(
      builder: (context, state) {
        if (state is SubCategoryLoading) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: grayColorForBorader),
                borderRadius: BorderRadius.circular(radiusValue),
              ),
              child: DropdownMenuItem<String>(
                value: "Select Sub Category",
                child: Row(
                  children: const [
                    SizedBox(width: 8),
                    Text("loading..."),
                  ],
                ),
              ));
        } else if (state is SubCategoryLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: grayColorForBorader),
                    borderRadius: BorderRadius.circular(radiusValue),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.selectedSubCategoryName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Icon(
                        _isDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isDropdownOpen)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: grayColorForBorader),
                    borderRadius: BorderRadius.circular(radiusValue),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Sub Category',
                            suffixIcon: state.isSearching
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    padding: const EdgeInsets.all(8),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(radiusValue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = state.subCategories[index];
                            return InkWell(
                              onTap: () {
                                context.read<SubCategoryBloc>().add(
                                      SelectSubCategory(
                                        subCategoryCode: subCategory['code'],
                                        subCategoryName: subCategory['name'],
                                      ),
                                    );
                                setState(() {
                                  _isDropdownOpen = false;
                                  _searchController.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: index ==
                                              state.subCategories.length - 1
                                          ? Colors.transparent
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  color: subCategory['name'] ==
                                          state.selectedSubCategoryName
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                child: Text(subCategory['name']),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        } else if (state is SubCategoryError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(radiusValue),
            ),
            child: Center(child: Text('Error: ${state.message}')),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: grayColorForBorader),
              borderRadius: BorderRadius.circular(radiusValue),
            ),
            child: Row(
              children: [
                const Expanded(child: Text('Loading...')),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ],
            ),
          );
        }
      },
    );
  }
}
