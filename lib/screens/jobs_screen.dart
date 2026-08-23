import 'dart:async';

import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../services/job_service.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({
    super.key,
  });

  @override
  State<JobsScreen> createState() =>
      _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  // =========================================================
  // SERVICE
  // =========================================================

  final JobService _jobService =
  JobService();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final ScrollController _scrollController =
  ScrollController();

  final TextEditingController _searchController =
  TextEditingController();

  // =========================================================
  // JOBS
  // =========================================================

  final List<Job> _jobs = [];

  // =========================================================
  // STATES
  // =========================================================

  bool _isLoading = true;

  bool _isLoadingMore = false;

  bool _isRefreshing = false;

  bool _hasMoreJobs = true;

  String? _errorMessage;

  // =========================================================
  // PAGINATION
  // =========================================================

  int _currentPage = 0;

  static const int _pageSize = 20;

  // =========================================================
  // SERVER SEARCH
  // =========================================================

  String _searchText = '';

  String _selectedFilter = 'All';

  Timer? _searchDebounce;

  int _requestId = 0;

  int _totalMatchingJobs = 0;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );

    _scrollController.addListener(
      _onScroll,
    );

    _loadInitialJobs();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _searchController.removeListener(
      _onSearchChanged,
    );

    _scrollController.removeListener(
      _onScroll,
    );

    _searchController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  // =========================================================
  // SCROLL
  // =========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            500) {
      _loadMoreJobs();
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _onSearchChanged() {
    final value =
    _searchController.text.trim();

    if (_searchText == value) {
      return;
    }

    _searchText = value;

    _searchDebounce?.cancel();

    _searchDebounce =
        Timer(
          const Duration(
            milliseconds: 450,
          ),
              () {
            _performNewSearch();
          },
        );

    // Immediately update the UI so the user sees
    // that a new search is being prepared.
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // PERFORM SEARCH
  // =========================================================

  Future<void> _performNewSearch() async {
    await _loadJobs(
      reset: true,
      showFullLoading: false,
    );
  }

  // =========================================================
  // LOAD INITIAL
  // =========================================================

  Future<void> _loadInitialJobs() async {
    await _loadJobs(
      reset: true,
      showFullLoading: true,
    );
  }

  // =========================================================
  // LOAD JOBS
  // =========================================================

  Future<void> _loadJobs({
    required bool reset,
    required bool showFullLoading,
  }) async {
    if (!mounted) {
      return;
    }

    // -------------------------------------------------------
    // NEW REQUEST ID
    // -------------------------------------------------------
    //
    // Prevent an older search response from replacing
    // a newer search response.
    // -------------------------------------------------------

    final int requestId =
    ++_requestId;

    if (showFullLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    if (reset) {
      _currentPage = 0;
      _hasMoreJobs = true;
      _totalMatchingJobs = 0;

      if (mounted) {
        setState(() {
          _jobs.clear();
        });
      }
    }

    try {
      final result =
      await _jobService.getJobsPage(
        page: 0,
        size: _pageSize,
        search: _searchText,
        jobType:
        _selectedFilter == 'All'
            ? null
            : _selectedFilter.toUpperCase(),
      );

      // -----------------------------------------------------
      // IGNORE OLD RESPONSE
      // -----------------------------------------------------

      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(() {
        _jobs.clear();

        _jobs.addAll(
          result.jobs,
        );

        _currentPage =
            result.page;

        _hasMoreJobs =
        !result.isLastPage;

        _totalMatchingJobs =
            result.totalElements;

        _isLoading = false;

        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            _cleanErrorMessage(e);
      });
    }
  }

  // =========================================================
  // LOAD MORE
  // =========================================================

  Future<void> _loadMoreJobs() async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMoreJobs) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final int requestId =
        _requestId;

    try {
      final nextPage =
          _currentPage + 1;

      final result =
      await _jobService.getJobsPage(
        page: nextPage,
        size: _pageSize,
        search: _searchText,
        jobType:
        _selectedFilter == 'All'
            ? null
            : _selectedFilter.toUpperCase(),
      );

      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(() {
        _jobs.addAll(
          result.jobs,
        );

        _currentPage =
            result.page;

        _hasMoreJobs =
        !result.isLastPage;

        _totalMatchingJobs =
            result.totalElements;

        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
      });

      _showMessage(
        _cleanErrorMessage(e),
      );
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> _refreshJobs() async {
    if (_isRefreshing) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final int requestId =
      ++_requestId;

      final result =
      await _jobService.getJobsPage(
        page: 0,
        size: _pageSize,
        search: _searchText,
        jobType:
        _selectedFilter == 'All'
            ? null
            : _selectedFilter.toUpperCase(),
      );

      if (!mounted ||
          requestId != _requestId) {
        return;
      }

      setState(() {
        _jobs.clear();

        _jobs.addAll(
          result.jobs,
        );

        _currentPage =
            result.page;

        _hasMoreJobs =
        !result.isLastPage;

        _totalMatchingJobs =
            result.totalElements;

        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _cleanErrorMessage(e);
      });

      _showMessage(
        _cleanErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // =========================================================
  // FILTER
  // =========================================================

  Future<void> _setFilter(
      String filter) async {
    if (_selectedFilter ==
        filter) {
      return;
    }

    setState(() {
      _selectedFilter =
          filter;
    });

    await _loadJobs(
      reset: true,
      showFullLoading: false,
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF6F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        Colors.white,
        foregroundColor:
        const Color(0xFF172033),

        title: const Text(
          'Jobs',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
            fontSize: 22,
          ),
        ),

        actions: [
          IconButton(
            tooltip:
            'Refresh jobs',
            onPressed:
            _isRefreshing
                ? null
                : _refreshJobs,
            icon:
            _isRefreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons
                  .refresh_rounded,
            ),
          ),

          const SizedBox(
            width: 6,
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null &&
        _jobs.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color:
      const Color(0xFF2563EB),

      backgroundColor:
      Colors.white,

      onRefresh:
      _refreshJobs,

      child:
      CustomScrollView(
        controller:
        _scrollController,

        physics:
        const AlwaysScrollableScrollPhysics(),

        slivers: [
          // =================================================
          // SEARCH
          // =================================================

          SliverToBoxAdapter(
            child:
            _buildSearchSection(),
          ),

          // =================================================
          // COUNT
          // =================================================

          SliverToBoxAdapter(
            child:
            _buildJobCount(),
          ),

          // =================================================
          // EMPTY
          // =================================================

          if (_jobs.isEmpty)
            SliverFillRemaining(
              hasScrollBody:
              false,
              child:
              _buildEmptyState(),
            )

          // =================================================
          // JOB LIST
          // =================================================

          else
            SliverPadding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                0,
                4,
                0,
                10,
              ),

              sliver:
              SliverList(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    final job =
                    _jobs[index];

                    return Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        bottom: 4,
                      ),

                      child:
                      _buildJobCard(
                        job,
                      ),
                    );
                  },

                  childCount:
                  _jobs.length,
                ),
              ),
            ),

          // =================================================
          // LOAD MORE
          // =================================================

          if (_isLoadingMore)
            SliverToBoxAdapter(
              child:
              _buildLoadingMore(),
            ),

          // =================================================
          // END
          // =================================================

          if (!_hasMoreJobs &&
              _jobs.isNotEmpty)
            SliverToBoxAdapter(
              child:
              _buildEndMessage(),
            ),

          const SliverToBoxAdapter(
            child:
            SizedBox(
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH SECTION
  // =========================================================

  Widget _buildSearchSection() {
    return Container(
      color:
      Colors.white,

      padding:
      const EdgeInsets
          .fromLTRB(
        16,
        14,
        16,
        14,
      ),

      child:
      Column(
        children: [
          TextField(
            controller:
            _searchController,

            textInputAction:
            TextInputAction.search,

            decoration:
            InputDecoration(
              hintText:
              'Search jobs, companies, countries...',

              hintStyle:
              TextStyle(
                color:
                Colors.grey.shade500,
                fontSize: 14,
              ),

              prefixIcon:
              const Icon(
                Icons.search_rounded,
                color:
                Color(0xFF2563EB),
              ),

              suffixIcon:
              _searchText.isNotEmpty
                  ? IconButton(
                tooltip:
                'Clear search',

                onPressed:
                    () {
                  _searchController
                      .clear();
                },

                icon:
                const Icon(
                  Icons
                      .close_rounded,
                ),
              )
                  : null,

              filled:
              true,

              fillColor:
              const Color(
                0xFFF4F6FA,
              ),

              contentPadding:
              const EdgeInsets
                  .symmetric(
                vertical: 16,
                horizontal: 16,
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  16,
                ),
                borderSide:
                BorderSide.none,
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  16,
                ),
                borderSide:
                BorderSide.none,
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  16,
                ),
                borderSide:
                const BorderSide(
                  color:
                  Color(
                    0xFF2563EB,
                  ),
                  width: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,

            physics:
            const BouncingScrollPhysics(),

            child:
            Row(
              children: [
                _filterChip(
                  label: 'All',
                  icon:
                  Icons.apps_rounded,
                  selected:
                  _selectedFilter ==
                      'All',
                ),

                const SizedBox(
                  width: 8,
                ),

                _filterChip(
                  label: 'Foreign',
                  icon:
                  Icons.public_rounded,
                  selected:
                  _selectedFilter ==
                      'Foreign',
                ),

                const SizedBox(
                  width: 8,
                ),

                _filterChip(
                  label: 'Domestic',
                  icon:
                  Icons.home_work_rounded,
                  selected:
                  _selectedFilter ==
                      'Domestic',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTER CHIP
  // =========================================================

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool selected,
  }) {
    return ChoiceChip(
      avatar:
      Icon(
        icon,
        size: 17,
        color:
        selected
            ? Colors.white
            : const Color(
          0xFF475569,
        ),
      ),

      label:
      Text(
        label,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
      ),

      selected:
      selected,

      onSelected:
          (_) {
        _setFilter(label);
      },

      labelStyle:
      TextStyle(
        fontWeight:
        FontWeight.w700,

        color:
        selected
            ? Colors.white
            : const Color(
          0xFF334155,
        ),
      ),

      selectedColor:
      const Color(
        0xFF2563EB,
      ),

      backgroundColor:
      const Color(
        0xFFF1F5F9,
      ),

      side:
      BorderSide.none,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),

      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 10,
        vertical: 8,
      ),
    );
  }

  // =========================================================
  // JOB COUNT
  // =========================================================

  Widget _buildJobCount() {
    final int loaded =
        _jobs.length;

    final int total =
        _totalMatchingJobs;

    return Padding(
      padding:
      const EdgeInsets
          .fromLTRB(
        16,
        17,
        16,
        10,
      ),

      child:
      Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFE8F0FF,
              ),

              borderRadius:
              BorderRadius
                  .circular(
                11,
              ),
            ),

            child:
            const Icon(
              Icons
                  .work_outline_rounded,
              size: 20,
              color:
              Color(
                0xFF2563EB,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  total > 0
                      ? '$total jobs found'
                      : '$loaded jobs loaded',

                  maxLines: 1,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Color(
                      0xFF172033,
                    ),
                  ),
                ),

                if (_hasMoreJobs)
                  Text(
                    'Showing $loaded • scroll for more',

                    maxLines: 1,

                    overflow:
                    TextOverflow
                        .ellipsis,

                    style:
                    TextStyle(
                      fontSize: 12,
                      color:
                      Colors.grey
                          .shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // JOB CARD
  // =========================================================

  Widget _buildJobCard(
      Job job) {
    return JobCard(
      job: job,

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                JobDetailsScreen(
                  job: job,
                ),
          ),
        );
      },
    );
  }

  // =========================================================
  // INITIAL LOADING
  // =========================================================

  Widget _buildLoadingState() {
    return Center(
      child:
      Padding(
        padding:
        const EdgeInsets.all(
          24,
        ),

        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Container(
              width: 68,
              height: 68,

              decoration:
              const BoxDecoration(
                color:
                Color(
                  0xFFE8F0FF,
                ),
                shape:
                BoxShape.circle,
              ),

              child:
              const Padding(
                padding:
                EdgeInsets.all(
                  20,
                ),

                child:
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color:
                  Color(
                    0xFF2563EB,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Finding jobs',
              style:
              TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
                color:
                Color(
                  0xFF172033,
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Loading the latest opportunities...',
              style:
              TextStyle(
                fontSize: 14,
                color:
                Colors.grey
                    .shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LOADING MORE
  // =========================================================

  Widget _buildLoadingMore() {
    return Padding(
      padding:
      const EdgeInsets
          .symmetric(
        vertical: 18,
      ),

      child:
      Row(
        mainAxisAlignment:
        MainAxisAlignment
            .center,

        children: [
          const SizedBox(
            width: 22,
            height: 22,

            child:
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color:
              Color(
                0xFF2563EB,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Text(
            'Loading more jobs...',
            style:
            TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.grey
                  .shade700,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // END MESSAGE
  // =========================================================

  Widget _buildEndMessage() {
    return Padding(
      padding:
      const EdgeInsets
          .symmetric(
        vertical: 18,
        horizontal: 24,
      ),

      child:
      Center(
        child:
        Text(
          _searchText.isNotEmpty
              ? 'All matching jobs have been loaded.'
              : 'You have reached the end of the available jobs.',

          textAlign:
          TextAlign.center,

          style:
          TextStyle(
            fontSize: 13,
            color:
            Colors.grey
                .shade600,
            fontWeight:
            FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState() {
    return Center(
      child:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          24,
        ),

        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration:
              const BoxDecoration(
                color:
                Color(
                  0xFFFFE8E8,
                ),
                shape:
                BoxShape.circle,
              ),

              child:
              Icon(
                Icons
                    .cloud_off_rounded,
                size: 40,
                color:
                Colors.red
                    .shade400,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Unable to load jobs',
              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
                color:
                Color(
                  0xFF172033,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              _errorMessage ??
                  'Something went wrong while loading jobs.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 14,
                height: 1.5,
                color:
                Colors.grey
                    .shade600,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            ElevatedButton.icon(
              onPressed:
              _loadInitialJobs,

              icon:
              const Icon(
                Icons
                    .refresh_rounded,
              ),

              label:
              const Text(
                'Try Again',
              ),

              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                const Color(
                  0xFF2563EB,
                ),
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    final bool hasSearch =
        _searchText.isNotEmpty;

    return Center(
      child:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          24,
        ),

        child:
        Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,

          children: [
            Container(
              width: 82,
              height: 82,

              decoration:
              const BoxDecoration(
                color:
                Color(
                  0xFFF1F5F9,
                ),
                shape:
                BoxShape.circle,
              ),

              child:
              Icon(
                hasSearch
                    ? Icons
                    .search_off_rounded
                    : Icons
                    .work_off_rounded,
                size: 42,
                color:
                Colors.grey
                    .shade400,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              hasSearch
                  ? 'No matching jobs'
                  : 'No jobs available',

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
                color:
                Color(
                  0xFF172033,
                ),
              ),
            ),

            const SizedBox(
              height: 9,
            ),

            Text(
              hasSearch
                  ? 'No jobs matched your search. Try another position, company, or country.'
                  : 'There are no jobs available for this filter right now.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 14,
                height: 1.5,
                color:
                Colors.grey
                    .shade600,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (hasSearch)
              OutlinedButton.icon(
                onPressed:
                    () {
                  _searchController
                      .clear();
                },

                icon:
                const Icon(
                  Icons
                      .close_rounded,
                ),

                label:
                const Text(
                  'Clear Search',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CLEAN ERROR
  // =========================================================

  String _cleanErrorMessage(
      Object error) {
    final message =
    error.toString();

    if (message.startsWith(
        'Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(
      String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(
          message,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
        ),

        behavior:
        SnackBarBehavior
            .floating,

        margin:
        const EdgeInsets.all(
          16,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }
}