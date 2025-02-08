erc_error_injector_configs = {
        "20": [
            ("return", {
                "function": "name",
                "numofargs": 0,
                "rule": "string, the name of the token, e.g., 'MyToken'",
                "severity": "medium"
            }),
            ("interface", {
                "function": "name",
                "numofargs": 0,
                "rule":"function name() public view returns (string)",
                "severity": "medium"
            }),
            ("return", {
                "function": "symbol",
                "numofargs": 0,
                "rule": "string, the symbol of the token",
                "severity": "medium"
            }),
            ("interface", {
                "function": "symbol",
                "numofargs": 0,
                "rule":"function symbol() public view returns (string)",
                "severity": "medium"
            }),
            ("return", {
                "function": "decimals",
                "numofargs": 0,
                "rule": "The number of decimal places the token can be divided into. This is used to define the smallest unit of the token for display and transaction purposes.",
                "severity": "medium"
            }),
            ("interface", {
                "function": "decimals",
                "numofargs": 0,
                "rule":"function decimals() public view returns (uint8)",
                "severity": "medium"
            }),
            ("return", {
                "function": "totalSupply",
                "numofargs": 0,
                "rule": "Returns the total token supply",
                "severity": "medium"
            }),
            ("interface", {
                "function": "totalSupply",
                "numofargs": 0,
                "rule": "function totalSupply() public view returns (uint256)",
                "severity": "medium"
            }),
            ("return", {
                "function": "balanceOf",
                "numofargs": 1,
                "rule": "the account balance of the account with address _owner",
                "severity": "high"
            }),
            ("interface", {
                "function": "balanceOf",
                "numofargs": 1,
                "rule": "function balanceOf(address _owner) public view returns (uint256 balance)",
                "severity": "medium"
            }),
            ("return", {
                "function": "transfer",
                "numofargs": 2,
                "rule": "Indicates whether the operation was successful",
                "severity": "medium"
            }),
            ("emit", {
                "function": "transfer",
                "numofargs": 2,
                "event": "Transfer",
                "rule":"emit event 'Transfer'",
                "severity": "low"
            }),
            ("interface", {
                "function": "transfer",
                "numofargs": 2,
                "rule": "function transfer(address _to, uint256 _value) public returns (bool success)",
                "severity": "medium"
            }),
            ("throw", {
                "function": "transferFrom",
                "numofargs": 3,
                "rule": "throw if the _from account has not deliberately authorized the sender of the message via some mechanism",
                "msgsender": True,
                "fn_params":[0],
                "severity": "high",
                "wr": 1
            }),
            ("return", {
                "function": "transferFrom",
                "numofargs": 3,
                "rule": "Indicates whether the token transfer was successful",
                "severity": "medium"
            }),
            ("emit", {
                "function": "transferFrom",
                "numofargs": 3,
                "event": "Transfer",
                "rule":"emit evnet 'Transfer'",
                "severity": "low"
            }),
            ("interface", {
                "function": "transferFrom",
                "numofargs": 3,
                "rule": "function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)",
                "severity": "medium"
            }),
            ("return", {
                "function": "approve",
                "numofargs": 2,
                "rule": "Indicates whether the approval was successful",
                "severity": "medium"
            }),
            ("assign", {
                "function": "approve",
                "numofargs": 2,
                "rule": "_spender overwrites the current allowance with _value.",
                "anchor_fn": "allowance",
                "severity": "high"
            }),
            ("emit", {
                "function": "approve",
                "numofargs": 2,
                "event": "Approval",
                "rule":"emit evnet 'Approval'",
                "severity": "low"
            }),
            ("interface", {
                "function": "approve",
                "numofargs": 2,
                "rule": "function approve(address _spender, uint256 _value) public returns (bool success)",
                "severity": "medium"
            }),
            ("return", {
                "function": "allowance",
                "numofargs": 2,
                "rule": "the amount which _spender is still allowed to withdraw from _owner",
                "severity": "medium"
            }),
            ("interface", {
                "function": "allowance",
                "numofargs": 2,
                "rule": "function allowance(address _owner, address _spender) public view returns (uint256 remaining)",
                "severity": "medium"
            }),
            ("emit", {
                "rule": " SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created",
                "event": "Transfer",
                "anchor_fn": "totalSupply",
                "severity": "low"
            }),
            ("emit", {
                "rule": "MUST trigger 'Transfer' when tokens are transferred, including zero value transfers",
                "event": "Transfer",
                "anchor_fn": "balanceOf",
                "severity": "low"
            })
        ],
        "721": [
            ("throw",{
                "rule": "throw if NFTs assigned to the zero address",
                "function": "balanceOf",
                "numofargs": 1,
                "fn_params":[0],
                "severity": "medium"
            }),
            ("return",{
                "rule": "The number of NFTs owned by `_owner`, possibly zero",
                "function": "balanceOf",
                "numofargs": 1,
                "severity": "high"
            }),
            ("throw", {
                "rule": " throw if NFTs assigned to zero address",
                "function":"ownerOf",
                "numofargs": 1,
                "fn_params":[0],
                "severity": "medium"
            }),
            ("return", {
                "rule": "The address of the owner of the NFT",
                "function":"ownerOf",
                "numofargs": 1,
                "severity": "high"
            }),
            ("throw",{
                "function":"safeTransferFrom",
                "numofargs": 4,
                "rule": " throw if `msg.sender` is not the current owner, an authorized operator, or the approved address for this NFT",
                "msgsender": True,
                "fn_params":[0],
                "severity": "high"
            }),
            ("throw",{
                "function":"safeTransferFrom",
                "numofargs": 4,
                "rule": " throw if `_from` is not the current owner",
                "fn_params":[0],
                "severity": "high"
            }),
            ("throw",{
                "function":"safeTransferFrom",
                "numofargs": 4,
                "rule": " throw if `_to` is the zero address",
                "fn_params":[1],
                "severity": "high"
            }),
            ("throw",{
                "function":"safeTransferFrom",
                "numofargs": 4,
                "rule": " throw if `_tokenId` is not a valid NFT",
                "fn_params":[2],
                "severity": "high"
            }),
            ("call", {
                "function":"safeTransferFrom",
                "numofargs": 4,
                "callee": "onERC721Received",
                "rule":"call 'onERC721Received' if `_to` is a smart contract (code size > 0)",
                "severity": "high"
            }),
            ("throw", {
                "function":"transferFrom",
                "numofargs": 3,
                "rule": " throw if `msg.sender` is not the current owner, an authorized operator, or the approved address for this NFT",
                "msgsender": True,
                "fn_params":[0],
                "severity": "high"
            }),
            ("throw", {
                "function":"transferFrom",
                "numofargs": 3,
                "rule": " throw if `_from` is not the current owner",
                "fn_params":[0],
                "severity": "high"
            }),
            ("throw", {
                "function":"transferFrom",
                "numofargs": 3,
                "rule": " throw if `_to` is the zero address",
                "fn_params":[1],
                "severity": "high"
            }),
            ("throw", {
                "function":"transferFrom",
                "numofargs": 3,
                "rule": " throw if `_tokenId` is not a valid NFT",
                "fn_params":[2],
                "severity": "high"
            }),
            ("throw", {
                "function":"approve",
                "numofargs": 2,
                "rule": " throw if `msg.sender` is not the current NFT owner or an authorized operator of the current owner",
                "msgsender": True,
                "fn_params":[0],
                "severity": "high"
            }),
            ("throw", {
                "function":"getApproved",
                "numofargs": 1,
                "rule": " throw if _tokenId is not a valid NFT",
                "fn_params":[0],
                "severity": "medium"
            }),
            ("return", {
                "function":"getApproved",
                "numofargs": 1,
                "rule": "The approved address for this NFT, or the zero address if there is none",
                "severity": "high"
            }),
            ("return", {
                "function":"isApprovedForAll",
                "numofargs": 2,
                "rule": "True if `_operator` is an approved operator for `_owner`, false otherwise",
                "severity": "high"
            }),
            ("emit", {
                "event": "Transfer",
                "anchor_fn": "balanceOf",
                "rule": "event 'Transfer' emits when ownership of any NFT changes by any mechanism.",
                "severity": "low"
            }),
            ("emit", {
                "event": "Approval",
                "anchor_fn": "getApproved",
                "rule":"event 'Transfer' emits when the approved address for an NFT is changed or reaffirmed",
                "severity": "low"
            }),
            ("emit", {
                "event": "ApprovalForAll",
                "anchor_fn": "isApprovedForAll",
                "rule": "event 'Transfer' when an operator is enabled or disabled for an owner.",
                "severity": "low"
            }),
            ("interface", {
                "function":"balanceOf",
                "numofargs": 1,
                "rule": "function balanceOf(address _owner) external view returns (uint256);",
                "severity": "medium"
            }),
            ("interface", {
                "function":"ownerOf",
                "numofargs": 1,
                "rule": "function ownerOf(uint256 _tokenId) external view returns (address);",
                "severity": "medium"
            }),
            ("interface", {
                "function":"safeTransferFrom",
                "numofargs": 4,
                "rule": "function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;",
                "severity": "medium"
            }),
            ("interface", {
                "function":"safeTransferFrom",
                "numofargs": 3,
                "rule": "function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;",
                "severity": "medium"
            }),
            ("interface", {
                "function":"safeTransferFrom",
                "numofargs": 3,
                "rule": "function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;",
                "severity": "medium"
            }),
            ("interface", {
                "function":"transferFrom",
                "numofargs": 3,
                "rule": "function transferFrom(address _from, address _to, uint256 _tokenId) external payable;",
                "severity": "medium"
            }),
            ("interface", {
                "function":"approve",
                "numofargs": 2,
                "rule": "function approve(address _approved, uint256 _tokenId) external payable;",
                "severity": "medium"
            }),
            ("interface", {
                "function":"setApprovalForAll",
                "numofargs": 2,
                "rule": "function setApprovalForAll(address _operator, bool _approved) external;",
                "severity": "medium"
            }),
            ("interface", {
                "function": "getApproved",
                "numofargs": 1,
                "rule": "function getApproved(uint256 _tokenId) external view returns (address);",
                "severity": "medium"
            }),
            ("interface", {
                "function": "isApprovedForAll",
                "numofargs": 2,
                "rule": "function isApprovedForAll(address _owner, address _operator) external view returns (bool);",
                "severity": "medium"
            })
        ],
        "1155": [
            ("interface", {
                "rule": "function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;",
                "function": "safeTransferFrom",
                "numofargs": 5,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;",
                "function": "safeBatchTransferFrom",
                "numofargs": 5,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "function balanceOf(address _owner, uint256 _id) external view returns (uint256);",
                "function": "balanceOf",
                "numofargs": 2,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);",
                "function": "balanceOfBatch",
                "numofargs": 2,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "function setApprovalForAll(address _operator, bool _approved) external;",
                "function": "setApprovalForAll",
                "numofargs": 2,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "function isApprovedForAll(address _owner, address _operator) external view returns (bool);",
                "function": "isApprovedForAll",
                "numofargs": 2,
                "severity": "medium"
            }),
            ("interface", {
                "rule": "event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value)",
                "severity": "medium"
            }),
            ("interface", {
                "rule": "event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values)",
                "event": "TransferBatch",
                "severity": "medium"
            }),
            ("interface", {
                "rule": "event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved)",
                "event": "ApprovalForAll",
                "severity": "medium"
            }),
            ("interface", {
                "rule": "event URI(string _value, uint256 indexed _id)",
                "event": "URI",
                "severity": "medium"
            }),
            ("throw", {
                "rule": " throw if `_to` is the zero address",
                "function": "safeTransferFrom",
                "numofargs": 5,
                "fn_params":[1],
                "severity": "high"
            }),
            ("call", {
                "function":"safeTransferFrom",
                "numofargs": 5,
                "callee": "onERC1155Received",
                "rule":"call 'onERC1155Received' if `_to` is a smart contract (code size > 0)",
                "severity": "high"
            }),
            ("throw", {
                "rule": "throw if Caller not be approved to manage the tokens being transferred out of the `_from` account",
                "function": "safeBatchTransferFrom",
                "numofargs": 5,
                "msgsender": True,
                "severity": "high"
            }),
            ("throw", {
                "rule": "throw if `_to` is the zero address",
                "function": "safeBatchTransferFrom",
                "numofargs": 5,
                "fn_params": [1],
                "severity": "high"
            }),
            ("throw", {
                "rule": " throw if length of `_ids` is not the same as length of `_values`",
                "function": "safeBatchTransferFrom",
                "numofargs": 5,
                "fn_params": [2, 3],
                "severity": "high"
            }),
            ("call", {
                "function":"safeBatchTransferFrom",
                "numofargs": 5,
                "callee": "onERC1155Received",
                "rule":"call 'onERC1155Received' if `_to` is a smart contract (code size > 0)",
                "severity": "high"
            }),
            ("return", {
                "function":"balanceOf",
                "numofargs": 2,
                "rule": "The _owner's balance of the token type requested",
                "severity": "high"
            }),
            ("return", {
                "function":"balanceOfBatch",
                "numofargs": 2,
                "rule": "The _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)",
                "severity": "high"
            }),
            ("return", {
                "function":"isApprovedForAll",
                "numofargs": 2,
                "rule": "True if the operator is approved, false if not",
                "severity": "high"
            })
        ]
    }